class UserRegistration < ActiveRecord::Base
  belongs_to :registration
  belongs_to :event
  attr_accessor :import_user_registration,:set_status_on_new_create
  before_validation :check_validation
  before_validation :update_status, :if => Proc.new{|p| ((p.set_status_on_new_create.present? and p.set_status_on_new_create == "true") or (p.import_user_registration.present? and p.import_user_registration == "true"))}
  before_validation :update_db_record
  before_save :walkin_status, if: Proc.new { |user_reg| user_reg.walk_in_registration and user_reg.registration_type == "walkin" }
  after_save :create_consent_questions
  # after_save :auto_approved
  after_create :generate_qr_code_for_registration, :genrate_uniq_confirmation_code

  has_attached_file :qr_code, {:styles => {:large => "200x200>",
                                         :small => "60x60>", 
                                         :thumb => "54x54>"}}.merge(USER_REGISTRATION_QR_CODE_PATH)

  validates_attachment_content_type :qr_code, :content_type => ["image/png"],:message => "please select valid format."

  validate :uniqueness_of_email, if: Proc.new { |p| p.import_user_registration.present? and p.import_user_registration == "true"}
  serialize :text_box_for_checkbox_or_radiobutton, JSON
  before_save :rename_image_file_name
  after_save :update_invitee_registration_status
  scope :entered_users, -> { where(registration_type: ["checkin", "walkin"]) }

  default_scope { order('created_at desc') }

  def uniqueness_of_email
    event = Event.find(self.event_id) if self.event_id.present?
    if event.present?
      registration_form = event.registrations.first
      identifier_key = registration_form.attributes["email_field"].downcase
      key = identifier_key
      existing_record = UserRegistration.where(key => self["#{key}"],"event_id" => self.event_id)
      Rails.logger.info "*************#{existing_record}.inspect"
      if existing_record.present?
        errors.add(key.to_sym, "#{self["#{key}"]} is already taken")
      end
      # unless existing_record.nil? || existing_record. == self.
      #     errors.add(:name, "Record #{existing_record.id} already has the name #{name}")
      # end
    end
  end

  include AASM
  aasm :column => :status do
    state :pending, :initial => true
    state :rejected
    state :approved
    state :confirmed
    # state :put_on_holded
    state :on_hold
    # state :mark_person_as_drop_outed
    state :drop_out
    
    event :approve do
      transitions :from => [:pending, :rejected,:on_hold], :to => [:approved]
    end 
    event :reject do
      transitions :from => [:pending,:approved,:confirmed,:on_hold], :to => [:rejected]
    end
    event :confirm do
      transitions :from => [:pending,:approved, :rejected,:on_hold,:drop_out], :to => [:confirmed]
    end 
    event :pending do
      transitions :from => [:approved,:confirmed,:rejected,:on_hold], :to => [:pending]
    end
    event :on_hold do
      transitions :from => [:approved, :confirmed, :pending, :rejected], :to => [:on_hold]
    end
    event :drop_out do
      transitions :from => [:approved,:confirmed], :to => [:drop_out]
    end
  end 

  def perform_event(event)
    if event == 'approve'
      self.approve!
      edm = Campaign.find_by_id(0).edms.where(:mail_to => "approved",:event_id => self.event_id).first
      edm.send_mail_to_register_user(self) if edm.present?
    elsif event == 'reject'
      self.reject! 
      edm = Campaign.find_by_id(0).edms.where(:mail_to => "rejected",:event_id => self.event_id).first
      edm.send_mail_to_register_user(self) if edm.present?
    elsif event == 'confirm'
      self.confirm! 
      edm = Campaign.find_by_id(0).edms.where(:mail_to => "confirmed",:event_id => self.event_id).first
      edm.send_mail_to_register_user(self) if edm.present?
    elsif event == 'pending'
      self.pending! 
    elsif event == 'on_hold'
      self.on_hold! 
    elsif event == 'drop_out'
      self.drop_out! 
    end
  end

  def consent_ques_answered_timezone
    if self.date_timestamp.present?
      self.date_timestamp + self.event.timezone_offset.to_i.seconds
    end
  end

  def email_field_value
    if registration.email_field.present?
      send(registration.email_field)
    end
  end
  
  def timestamp
    (self.created_at + self.event.timezone_offset.to_i.seconds).strftime("%d/%m/%Y %T")
  end
  
  def update_invitee_registration_status
    event = self.event
    email_address = self[registration["email_field"]]
    invitee_structure = event.invitee_structures.first
    invitee_datum = invitee_structure.invitee_datum.where("attr1  LIKE '%#{email_address}%'") if invitee_structure.present?
    if invitee_datum.present? and invitee_datum.first.present?
      invitee_datum.first.update_column(:registration_status, self.status)
      invitee_datum.first.update_column(:telecaller_update_count, invitee_datum.first.telecaller_update_count.to_i + 1)
    end
  end

  def check_validation
    event = Event.find(self.event_id)
    registration = event.registrations
    registration.each do |validation|
      attre = validation.attributes.except("id", "event_id","created_at", "updated_at","custom_css","custom_js","custom_source_code", 'status','email_field', 'disclaimer_text')
      attre.each do |regi_valid|
        self_attre = self.attributes.except("id", "registration_id","invitee_id", "event_id",'created_at','updated_at','text_box_for_checkbox_or_radiobutton','status','disclaimer_text')
        self_attre.each do |user_regi_valid|
          if (regi_valid[1].present? and regi_valid[1][:mandatory_field].present?)
            self.validation_and_mandate_present(regi_valid,user_regi_valid)
          end
          if regi_valid[1].present? and regi_valid[1][:validation_type].present?
            self.validation_present(regi_valid,user_regi_valid)
          end
        end
      end
    end
  end 

  def validation_and_mandate_present(regi_valid,user_regi_valid)
    errors.add(user_regi_valid[0], "This field is required.") if((regi_valid[1][:mandatory_field].present? and regi_valid[1][:mandatory_field] == "yes") and regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].blank?)
  end

  def update_status
    if self.status.present?
      status = self.status
      event_id = self.event_id
      registration_setting = RegistrationSetting.where(:event_id => event_id).last
      registration = Registration.where(:event_id => event_id).last
      if (registration_setting.present? and registration_setting.auto_approved == 'yes')
      # status = (registration_setting.present? and registration_setting.auto_approved == 'yes') ? 'approved' : 'pending'
        domain_names = registration_setting.auto_approved_domain_validation.split(',')
        if domain_names.present? and self[registration["email_field"]].present?
          user_email_domain = self[registration["email_field"]].split(/(?=[@])/).second
          status = (domain_names.include?(user_email_domain) ? "approved" : "pending")
        else
          status = "approved"
        end
      end
      if (registration_setting.present? and registration_setting.auto_rejected == 'yes')
        domain_names = registration_setting.auto_rejected_domain_validation.split(',')
        unless self.qr_code_registration
          if domain_names.present? and self[registration["email_field"]].present?
            user_email_domain = self[registration["email_field"]].split(/(?=[@])/).second
            status = (domain_names.include?(user_email_domain) ? "rejected" : status)
          else
            status = "rejected"
          end
        end
      end
      if status =="approved" and self.registration_type == "walkin"
        status = "confirmed"
      end  
      auto_approved_user_list = AutoStatusEmail.where(:event_id => self.event_id)
      email_field = self.event.registrations.first.email_field
      if auto_approved_user_list.present?
        if auto_approved_user_list.pluck(:auto_approved_email).compact.include?(self.send(email_field))
          status ="approved"   
        elsif auto_approved_user_list.pluck(:auto_reject_email).compact.include?(self.send(email_field))
          status ="rejected"
        end
      end    
      self.registration_id = registration.id if registration.present? and self.registration_id.blank?
      self.status = status if self.status.present?
      self.previous_status = status_was
    end
  end

  def validation_present(regi_valid,user_regi_valid)
    if regi_valid[1][:validation_type] == "Mandatory"
      errors.add(user_regi_valid[0], "This field is required.") if regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].blank?
    elsif regi_valid[1].present? and regi_valid[1][:validation_type] == "Email Validation"
      errors.add(user_regi_valid[0], "Sorry, this doesn't look like a valid email.") if regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].present? and user_regi_valid[1].match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i) == nil
    elsif regi_valid[1].present? and regi_valid[1][:validation_type] == "Numeric only"
      errors.add(user_regi_valid[0], "This field required only Numeric. ") if (regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].present? and (user_regi_valid[1] =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/ ? false : true))
    elsif regi_valid[1].present? and regi_valid[1][:validation_type] == "Text only"
      errors.add(user_regi_valid[0], "This field required only Text. ") if (regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].present? and (user_regi_valid[1] =~ /\A[a-zA-Z\s*]+\z/x ? false : true))
      


      
    end      
  end

  def mandate_present(regi_valid,user_regi_valid)
    errors.add(user_regi_valid[0], "This field is required.") if((regi_valid[1][:mandatory_field].present? and regi_valid[1][:mandatory_field] == "yes") and regi_valid[0] == user_regi_valid[0] and user_regi_valid[1].blank?)
  end

  def generate_qr_code_for_registration
    if self.event.present? and self.qr_code.blank?
      self.qr_code = QRCode.generate_qr_code_for_registration("#{self.event.id}", self.id)
      self.save(:validate => false)
    end
  end

  def genrate_uniq_confirmation_code
    if self.unique_confirmation_code.blank? and self.field1.present?
      code = self.field1.first(4) rescue rand.to_s[2..5]
      code += (self.id).to_s
      self.update_column('unique_confirmation_code',code)
    end
  end

  def update_db_record
    event = Event.find(self.event_id)
    registration = event.registrations.last.attributes.except('id', 'created_at', 'updated_at', 'event_id','custom_css','custom_js','custom_source_code','parent_id','multi_lng_parent_id','language_updated')#.map{|k, v| (v.present? and v['label'].present?) ? k : nil}.compact
    user_registration = self.attributes.except('id', 'created_at', 'updated_at', 'registration_id','event_id','invitee_id','text_box_for_checkbox_or_radiobutton','status','parent_id','unique_confirmation_code','qr_code_file_name','qr_code_content_type','qr_code_file_size','qr_code_updated_at')#.map{|k, v| (v.present?) ? {k => v} : nil}.compact
    db_data = InviteeDatum.find_or_initialize_by(:invitee_structure_id => event.invitee_structures.last.id, :attr1 => user_registration["#{registration["email_field"]}"]) if event.invitee_structures.present?
    invitee = Invitee.find_or_initialize_by(:email => user_registration["#{registration["email_field"]}"], :event_id => event.id)
    flag = 0
    registration.each do |regi|
      if regi[1].present?
        if regi[1]["db_map_column_name"].present?
          if db_data.present?
            if db_data.new_record?
              db_data.assign_attributes("#{regi[1]["db_map_column_name"]}" => user_registration["#{regi[0]}"]) if user_registration["#{regi[0]}"].present?
              db_data.save
            else
              db_data.update_column("#{regi[1]["db_map_column_name"]}",user_registration["#{regi[0]}"]) if user_registration["#{regi[0]}"].present?
              if flag == 0
                count = (db_data.registration_update_count.present? ? (db_data.registration_update_count.to_i + 1) : "1")
                db_data.update_column('registration_update_count',count)
                flag = 1
              end
            end
          end
        end
        if regi[1]["invitee_map_column_name"].present?
          if invitee.present?
            if invitee.new_record?
              if regi[1]["invitee_map_column_name"] == "first_name"
                invitee.assign_attributes("#{regi[1]["invitee_map_column_name"]}" => user_registration["#{regi[0]}"],"last_name" => ".") if user_registration["#{regi[0]}"].present?
                invitee.save
              elsif regi[1]["invitee_map_column_name"] == "last_name"
                invitee.assign_attributes("#{regi[1]["invitee_map_column_name"]}" => user_registration["#{regi[0]}"],"first_name" => ".") if user_registration["#{regi[0]}"].present?
                invitee.save
              elsif ["first_name","last_name"].exclude?(regi[1]["invitee_map_column_name"])
                invitee.assign_attributes("#{regi[1]["invitee_map_column_name"]}" => user_registration["#{regi[0]}"],"first_name" => ".","last_name" => ".") if user_registration["#{regi[0]}"].present?
                invitee.save
              end
              # invitee.assign_attributes("#{regi[1]["invitee_map_column_name"]}" => user_registration["#{regi[0]}"]) if user_registration["#{regi[0]}"].present?
              # invitee.save(:validate => false)
            else
              invitee.update_attribute("#{regi[1]["invitee_map_column_name"]}",user_registration["#{regi[0]}"]) if user_registration["#{regi[0]}"].present?
            end
          end
        end
      end
    end
  end

  def create_consent_questions
    event = Event.find(self.event_id)
    registration = event.registrations.last.attributes.except('id', 'created_at', 'updated_at', 'event_id','custom_css','custom_js','custom_source_code','parent_id','multi_lng_parent_id','language_updated','disclaimer_text')
    user_registration = self.attributes.except('id', 'created_at', 'updated_at', 'registration_id','event_id','invitee_id','text_box_for_checkbox_or_radiobutton','status','parent_id','unique_confirmation_code','qr_code_file_name','qr_code_content_type','qr_code_file_size','qr_code_updated_at')
    registration.each do |regi|
      if regi[1].present?
        if regi[1]["db_map_column_name"].present?
          (1..10).each do |count|
            if regi[1]["db_map_column_name"] == "consent_question_#{count}"
              self.update_column(:"consent_question_#{count}", regi[1]['label'])
              self.update_column(:"consent_answer_#{count}", user_registration["#{regi[0]}"])
            end
          end
          self.update_column(:date_timestamp, Time.now)
        end
      end
    end
  end

  def rename_image_file_name
    if (self.qr_code_updated_at_changed? and self.qr_code_file_name.present?)
      extension = File.extname(qr_code_file_name).downcase
      self.qr_code_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end
  def self.user_registration_data(event)
    event.user_registrations
  end

  def self.user_registration_count(event)
    # db_map_column_name = ''
    email_field = event.registrations.last["email_field"] if event.registrations.present?
    # registration = event.registrations.last.attributes.except('id', 'created_at', 'updated_at', 'event_id','custom_css','custom_js','custom_source_code','parent_id').each do |e|
    #   if e[1].present? and (e[1]["db_map_column_name"].present? or e[1]["invitee_map_column_name"].present?)
    #     db_map_column_name = e[1]["db_map_column_name"] if (email_field == e[0])
    #   end
    # end
    reg_email = email_field.present? ? event.user_registrations.pluck("#{email_field}") : []
    # reg_db_users = db_map_column_name.present? ? event.invitee_structures.last.invitee_datum.pluck("#{db_map_column_name}") : []
    reg_db_users = event.invitee_structures.last.invitee_datum.pluck(:attr1)
    count = []
    reg_db_users.map{|x| count << x if reg_email.include? x}
    count
  end

  def self.registration_field_values
    if count > 0
      field_values = []
      event = first.event
      event.onsite_accessible_columns.selected_columns.each do |field|
        field_values << event.user_registrations.map(&:"#{field}")
      end
      field_values.flatten.compact.uniq
    end
  end

  def field2_and_field3
    if field2 && field3
      "#{field2} #{field3}"
    elsif field2
      field2
    elsif field3
      field3
    end
  end

  def reg_type_checkin?
    registration_type == 'checkin'
  end

  def check_same_event?(event)
    (event_id == event.id)
  end

  def update_checkin_status
    update_columns(registration_type: 'checkin', qr_code_registration: true, qr_code_registration_time: Time.now)
  end

  private

  def walkin_status
    self.status = 'approved'
  end

end
