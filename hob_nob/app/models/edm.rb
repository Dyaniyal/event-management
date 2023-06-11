class Edm < ActiveRecord::Base
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am,:start_date_time,:update_mail,:step,:check_field_value, :next
  belongs_to :campaign
  has_many :edm_mail_sents
  has_many :track_links, :dependent => :destroy
  serialize :social_icons, Array
  serialize :consent_links, Array

  has_attached_file :header_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(HEADER_IMAGE_PATH)

  has_attached_file :footer_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(FOOTER_IMAGE_PATH)

  # before_validation :set_time, :if => Proc.new{}
  validate :check_template_or_custom_is_present
  validates :reply_to_email, presence: { :message => "This field is required." }
  validates_attachment_content_type :header_image,:footer_image, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  validate :image_dimensions
  validate :sender_name_presence, if: Proc.new { |p| p.next.present?}
  validate :cc_email, if: Proc.new { |p| p.next.present? and p.cc.present?}
  validate :bcc_email, if: Proc.new { |p| p.next.present? and p.bcc.present?}
  before_validation :set_sent_to_no
  # after_save :send_mail_to_invitees
  after_create :set_event_timezone
  after_save :update_edm_id_to_track_link_1
  after_save :update_edm_id_to_track_link_2
  after_save :update_edm_id_to_track_link_3
  after_save :update_edm_id_to_track_link_4
  after_save :update_edm_id_to_track_link_5
  after_save :update_edm_id_to_track_link_6
  after_save :update_edm_id_to_track_link_7
  after_save :update_edm_id_to_track_link_8
  after_save :update_edm_id_to_track_link_9
  after_save :update_edm_id_to_track_link_10
  
  scope :ordered, -> { order('created_at desc') }

  def update_edm_id_to_track_link_1
    if self.track_link_1_id.present?
      track_id = self.track_link_1_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end
  
  def update_edm_id_to_track_link_2
    if self.track_link_2_id.present?
      track_id = self.track_link_2_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end
  
  def update_edm_id_to_track_link_3
    if self.track_link_3_id.present?
      track_id = self.track_link_3_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end
  
  def update_edm_id_to_track_link_4
    if self.track_link_4_id.present?
      track_id = self.track_link_4_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end
  
  def update_edm_id_to_track_link_5
    if self.track_link_5_id.present?
      track_id = self.track_link_5_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end  
  
  def update_edm_id_to_track_link_6
    if self.track_link_6_id.present?
      track_id = self.track_link_6_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end

  def update_edm_id_to_track_link_7
    if self.track_link_7_id.present?
      track_id = self.track_link_7_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end

  def update_edm_id_to_track_link_8
    if self.track_link_8_id.present?
      track_id = self.track_link_8_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end

  def update_edm_id_to_track_link_9
    if self.track_link_9_id.present?
      track_id = self.track_link_9_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end

  def update_edm_id_to_track_link_10
    if self.track_link_10_id.present?
      track_id = self.track_link_10_id
      TrackLink.find(track_id).update_column(:edm_id, self.id)
    end
  end

  def cc_email
    value = self.cc.split(",")
    value.each do |p|
      unless p =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
        errors.add(:cc, "Please Enter Valid Email.")
      end
    end
  end


  def sender_name_presence
    errors.add(:sender_name, "This field is required.") if self.sender_name.blank?
  end

  def bcc_email
    value = self.bcc.split(",")
    value.each do |p|
      unless p =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        errors.add(:bcc, "Please Enter Valid Email.")
      end
    end
  end
  
  def set_sent_to_no
    if self.new_record? and self.sent.blank?
      self.sent = 'no'
    end
  end

  def set_time(start_date_time,start_time_hour,start_time_minute,start_time_am)
    if start_date_time.present?
      start_date = "#{start_date_time} #{start_time_hour.gsub(':', "") rescue nil}:#{start_time_minute.gsub(':', "")rescue nil}:#{0} #{start_time_am}"
      start_date = start_date.to_datetime rescue nil
      puts 1111111111111
      self.edm_broadcast_time = start_date
    end
  end
  
  # def set_time_for_now(start_date_time,start_time_hour,start_time_minute,start_time_am)
  #   if start_date_time.present?
  #     start_date = "#{start_date_time} #{start_time_hour}:#{start_time_minute}:#{0} #{start_time_am}"
  #     start_date = start_date.to_datetime rescue nil
  #     self.edm_broadcast_time = start_date
  #   end
  # end

  # def self.send_email_time_basis
  #   puts "*************EDM********#{Time.now}**********************"
  #   edms = Edm.where("sent != ? and edm_broadcast_time < ? and edm_broadcast_time > ?", 'yes', (Time.zone.now).to_formatted_s(:db), (Time.zone.now - 30.minutes).to_formatted_s(:db))
  #   if edms.present?
  #     edms.each do |edm|
  #       edm.send_mail_to_invitees
  #     end
  #   end
  # end

  def self.send_email_time_basis
    puts "*************EDM********#{Time.now}**********************"
    edms = Edm.where("sent != ?", 'yes')
    if edms.present?
      edms.each do |edm|
        current_time_in_time_zone = Time.now + edm.event_timezone_offset.to_i.seconds
        if edm.edm_broadcast_time.present? and (edm.edm_broadcast_time <= current_time_in_time_zone) and (edm.edm_broadcast_time >= (current_time_in_time_zone - 30.minutes))
          puts "*******#{edm.id}*********#{edm.event_id}*************"          
          edm.send_mail_to_invitees
        end
      end
    end
  end

  def send_mail_to_invitees()
    # if self.edm_broadcast_value == 'now'
      edm = self
      self.update_column(:edm_broadcast_time, Time.now)
      self.update_column(:sent, 'yes')
      final_emails_arr = []
      campaign = self.campaign
      event = Event.find(self.event_id)
      # smtp_setting = event.get_licensee_admin.smtp_setting
      smtp_setting = event.smtp_setting.present? ? event.smtp_setting : event.get_licensee_admin.smtp_setting
      invitee_structure = event.invitee_structures.last
      database_email_field = (invitee_structure.present? ? (invitee_structure.email_field.present? ? invitee_structure.email_field : "") : "")
      database_data = (invitee_structure.present? ? invitee_structure.invitee_datum : "")
      if self.rejected_domain.present?
        database_field = database_data.pluck("#{database_email_field}")
        matched = []
        database_field.each do |field|
          if field.include? "#{self.rejected_domain}"
            matched << field
          end
        end
        final_emails_arr = database_field - matched
      elsif invitee_structure.present? and edm.group_type == 'apply filter' and edm.group_id.present?
        registration = event.registrations.last
        registration_email_field = registration.email_field rescue nil
        user_registrations = UserRegistration.where(:registration_id => registration.id) if registration.present?
        invitee_data_per_group = InviteeDatum.get_invitee_data_as_per_group(self.event_id,self.group_id)
        user_registration_emails = []
        if user_registrations.present?
          user_registration_emails = user_registrations.pluck("#{registration_email_field}")
          if edm.registered == 'yes' and registration_email_field.present? and database_email_field.present?
            # user_registration_emails = InviteeDatum.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, user_registration_emails).pluck("#{database_email_field}")
            user_registration_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, user_registration_emails).pluck("#{database_email_field}")
          elsif edm.registered == 'no' and registration_email_field.present? and database_email_field.present?
            if user_registration_emails.present? and 
              user_registration_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} Not IN (?)", invitee_structure.id, user_registration_emails).pluck("#{database_email_field}")
            else
              user_registration_emails = invitee_data_per_group.where(:invitee_structure_id => invitee_structure.id).pluck("#{database_email_field}")
            end
          end
        end   

        user_email_sent = []
        if edm.email_sent.present? and database_email_field.present?
          campaign = edm.campaign
          edm_ids = campaign.edms.pluck(:id)
          email_sent_yes = EdmMailSent.where("edm_id IN (?)",edm_ids)
          email_sent_yes_arr = email_sent_yes.pluck(:email)
          if edm.email_sent == 'yes'
            user_email_sent = InviteeDatum.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, email_sent_yes_arr).pluck("#{database_email_field}")
          elsif edm.email_sent == 'no'
            user_email_sent = InviteeDatum.where("invitee_structure_id = ? and #{database_email_field} NOT IN (?)", invitee_structure.id, email_sent_yes_arr).pluck("#{database_email_field}")
          end
        end

        user_email_opened = []
        if edm.email_opened.present? and database_email_field.present?
          if edm.email_opened == 'yes'
            email_opened_yes_arr = EdmMailSent.where(:edm_id => edm.id,:open => 'yes').pluck(:email)
            #final_emails_arr = final_emails_arr & email_opened_yes_arr
            user_email_opened = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, email_opened_yes_arr).pluck("#{database_email_field}")
          elsif edm.email_opened == 'no'
            email_opened_no_arr = EdmMailSent.where(:edm_id => edm.id,:open => 'no').pluck(:email)
            #final_emails_arr = final_emails_arr - email_opened_yes_arr
            user_email_opened = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, email_opened_no_arr).pluck("#{database_email_field}")
          end
        end

        database_approved_emails = []
        if edm.registration_approved.present? and user_registrations.present? and registration_email_field.present? and database_email_field.present?
          if edm.registration_approved == 'yes'
            user_registration_approved_emails = user_registrations.where(:status => 'approved').pluck("#{registration_email_field}")
            database_approved_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, user_registration_approved_emails).pluck("#{database_email_field}")
          elsif edm.registration_approved == 'no'
            user_registration_approved_emails = user_registrations.where('status != ?','approved').pluck("#{registration_email_field}")
            database_approved_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, user_registration_approved_emails).pluck("#{database_email_field}")
          end
        end

        database_confirm_emails = []
        if edm.confirmed.present? and user_registrations.present? and registration_email_field.present? and database_email_field.present?
          if edm.confirmed == 'yes'
          confirm_emails = user_registrations.where(:status=>"confirmed",:qr_code_registration => true).pluck("#{registration_email_field}")
          database_confirm_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, confirm_emails).pluck("#{database_email_field}")
          elsif edm.confirmed == 'no'
            confirm_emails = user_registrations.where('status != ? AND qr_code_registration != ?','confirmed', true).pluck("#{registration_email_field}")
            database_confirm_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, confirm_emails).pluck("#{database_email_field}")
          end
        end

        database_rejected_emails = []
        if edm.registration_rejected.present? and user_registrations.present? and registration_email_field.present? and database_email_field.present?
          if edm.registration_rejected == 'yes'
          rejected_emails = user_registrations.where(:status=>"rejected").pluck("#{registration_email_field}")
          database_rejected_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, rejected_emails).pluck("#{database_email_field}")
          elsif edm.registration_rejected == 'no'
            rejected_emails = user_registrations.where('status != ?','rejected').pluck("#{registration_email_field}")
            database_rejected_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, rejected_emails).pluck("#{database_email_field}")
          end
        end

        database_pending_emails = []
        if edm.registration_pending.present? and user_registrations.present? and registration_email_field.present? and database_email_field.present?
          if edm.registration_pending == 'yes'
          pending_emails = user_registrations.where(:status=>"pending").pluck("#{registration_email_field}")
          database_pending_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, pending_emails).pluck("#{database_email_field}")
          elsif edm.registration_pending == 'no'
            pending_emails = user_registrations.where('status != ?','pending').pluck("#{registration_email_field}")
            database_pending_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, pending_emails).pluck("#{database_email_field}")
          end
        end

        database_attended_emails = []
        if edm.attended.present? and user_registrations.present? and registration_email_field.present? and database_email_field.present?
          if edm.attended == 'yes'
            attended_emails = user_registrations.where(:qr_code_registration => true).pluck("#{registration_email_field}")
            database_attended_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, attended_emails).pluck("#{database_email_field}")
          else
            attended_emails = user_registrations.where(:qr_code_registration => false).pluck("#{registration_email_field}")
            database_attended_emails = invitee_data_per_group.where("invitee_structure_id = ? and #{database_email_field} IN (?)", invitee_structure.id, attended_emails).pluck("#{database_email_field}")
          end
        end

        final_emails_arr = user_registration_emails if user_registration_emails.present?

        final_emails_arr = (user_email_sent.present? ? (final_emails_arr.present? ? final_emails_arr & user_email_sent : user_email_sent) : final_emails_arr)

        final_emails_arr = (user_email_opened.present? ? (final_emails_arr.present? ? final_emails_arr & user_email_opened : user_email_opened) : final_emails_arr)

        final_emails_arr = (database_approved_emails.present? ? (final_emails_arr.present? ? final_emails_arr & database_approved_emails : database_approved_emails) : final_emails_arr)

        final_emails_arr = (database_confirm_emails.present? ? (final_emails_arr.present? ? final_emails_arr & database_confirm_emails : database_confirm_emails) : final_emails_arr)

        final_emails_arr = (database_rejected_emails.present? ? (final_emails_arr.present? ? final_emails_arr & database_rejected_emails : database_rejected_emails) : final_emails_arr)  

        final_emails_arr = (database_pending_emails.present? ? (final_emails_arr.present? ? final_emails_arr & database_pending_emails : database_pending_emails) : final_emails_arr)   

        final_emails_arr = (database_attended_emails.present? ? (final_emails_arr.present? ? final_emails_arr & database_attended_emails : database_attended_emails) : final_emails_arr)


        final_emails_arr1 = final_emails_arr
        final_emails_arr = get_subscribed_users(final_emails_arr1,self.event_id,self.id) 
      elsif invitee_structure.present?
        invitee_data_as_per_group = InviteeDatum.get_invitee_data_as_per_group(self.event_id,self.group_id)
        final_emails_arr1 = invitee_data_as_per_group.pluck("#{database_email_field}") rescue []
        #final_emails_arr1 = InviteeDatum.where(:invitee_structure_id => invitee_structure.id).pluck("#{database_email_field}") rescue []
        final_emails_arr = get_subscribed_users(final_emails_arr1,self.event_id,self.id)
      end  
      if smtp_setting.present? and final_emails_arr.present?
        final_emails_arr.each do |email|
          email_sent = EdmMailSent.find_or_initialize_by(:event_id => event.id, :email => email, :edm_id => self.id)
          if self.campaign.invitee_campaign == "yes"
            email_sent.invitee_campaign = true
          end  
          email_sent.save
          # subscribe_user = Unsubscribe.find_or_initialize_by(:event_id => event.id,:edm_id => self.id,:email => email)
          subscribe_user = Unsubscribe.find_or_initialize_by(:event_id => event.id,:email => email)
          subscribe_user.save
          # invitee_name = Invitee.where(:event_id => event.id, :email => email).first.first_name
          
          # invitee_data = Invitee.where(:event_id => event.id, :email => email)
          # invitee_name = invitee_data.present? ? invitee_data.first.first_name : []
          UserMailer.default_template(edm,email,smtp_setting,"",database_data,database_email_field).deliver_now if edm.template_type.present? and edm.template_type == "default_template"
          UserMailer.custom_template(edm,email,smtp_setting,"",database_data,database_email_field).deliver_now if edm.template_type.present? and edm.template_type == "custom_template" 
        end
      end
    # end
  end

  def send_mail_to_register_user(user_registration=nil)
    return unless self.active
    edm = self
    #self.update_column(:edm_broadcast_time, Time.now)
    self.update_column(:sent, 'yes')
    final_emails_arr = []
    event_id = self.event_id
    event = Event.find(event_id)
    #smtp_setting = event.get_licensee_admin.smtp_setting
    smtp_setting = event.smtp_setting.present? ? event.smtp_setting : event.get_licensee_admin.smtp_setting
    registration_email_field = event.registrations.first.email_field
    final_emails_arr = [user_registration[registration_email_field]]
    if smtp_setting.present? and final_emails_arr.present?
      final_emails_arr.each do |email|
        email_sent = EdmMailSent.find_or_initialize_by(:event_id => event.id, :email => email, :edm_id => self.id)
        email_sent.save
        #subscribe_user = Unsubscribe.find_or_initialize_by(:event_id => event.id,:edm_id => self.id,:email => email)
        subscribe_user = Unsubscribe.find_or_initialize_by(:event_id => event.id,:email => email)
        subscribe_user.save
        #data = Unsubscribe.where(:event_id => event.id,:edm_id => self.id,:email => email,:unsubscribe => "false")
        data = Unsubscribe.where(:event_id => event.id,:email => email,:unsubscribe => "false")
        unsubscribe_user = data.present? ? data.first : []
        if unsubscribe_user.present?
          UserMailer.default_template(edm,email,smtp_setting,user_registration,"",registration_email_field).deliver_now if edm.template_type.present? and edm.template_type == "default_template"
          UserMailer.custom_template(edm,email,smtp_setting,user_registration,"",registration_email_field).deliver_now if edm.template_type.present? and edm.template_type == "custom_template"
        end
      end
    end
  end

  def check_template_or_custom_is_present
    # if self.template_type == "default_template" 
    #   errors.add(:default_template, "This field is required.") if self.default_template.blank?
    # end
    if self.template_type == "custom_template"
      errors.add(:custom_code, "This field is required.") if self.custom_code.blank?
    end
  end


  # def sent_mail(edm,event)
  #   grouping = Grouping.find(edm.group_id) rescue nil
  #   invitee_structure = event.invitee_structures.first if event.invitee_structures.present?
  #   invitee_data = invitee_structure.invitee_datum rescue nil
  #   data = Grouping.get_search_data_count(invitee_data, [grouping]) if grouping.present? and invitee_data.present?
  #   smtp_setting = SmtpSetting.last
  #   if smtp_setting.present? and data.present?
  #     data.each do |f|
  #       email = f["#{edm.database_email_field}"] 
  #       UserMailer.default_template(edm,email,smtp_setting).deliver_now if edm.template_type.present? and edm.template_type == "default_template"
  #       UserMailer.custom_template(edm,email,smtp_setting).deliver_now if edm.template_type.present? and edm.template_type == "custom_template"
  #     end
  #   end
  # end

  def image_dimensions
    if header_image_file_name.present? and header_image_file_name_changed?
      edm_header_image_height, edm_header_image_width  = 105.0, 600.0
      dimensions_header_image = Paperclip::Geometry.from_file(header_image.queued_for_write[:original].path) if header_image_file_name.present?
      errors.add(:header_image, "Image size should be 600x105px only") if (dimensions_header_image.width != edm_header_image_width or dimensions_header_image.height != edm_header_image_height)
    end
  end
   
  def get_subscribed_users(final_emails_arr1,event_id,edm_id)
    subscribe_users = Unsubscribe.where('email IN (?) AND unsubscribe = ? AND event_id = ?',final_emails_arr1,"false",event_id) if final_emails_arr1.present? 
    get_new_users = subscribe_users.present? ? (final_emails_arr1 - subscribe_users.pluck(:email)) : final_emails_arr1
    unsubscribe_users = Unsubscribe.where('email IN (?) AND unsubscribe = ? AND event_id = ?',final_emails_arr1,"true",event_id) if final_emails_arr1.present? 
    get_new_users = (get_new_users - unsubscribe_users.pluck(:email)) if unsubscribe_users.present?
    subscribe_plus_new_users = (subscribe_users.present? or unsubscribe_users.present?) ? (subscribe_users.pluck(:email) + get_new_users) : final_emails_arr1
    final_emails_arr = ((subscribe_users.present? or unsubscribe_users.present?) ? subscribe_plus_new_users  : final_emails_arr1)
  end 

  def check_sender_name_and_email_present
    if self.sender_name.blank? #self.sender_email.blank? or
      #errors.add(:sender_email, "This field is required.") if self.sender_email.blank?
      errors.add(:sender_name, "This field is required.") if self.sender_name.blank?
    end
  end

  def set_event_timezone
    event = Event.find_by_id(self.event_id) if self.event_id.present?
    if event.present?
      self.update_column("event_timezone", event.timezone)
      self.update_column("event_timezone_offset", event.timezone_offset)
      self.update_column("event_display_time_zone", event.display_time_zone)
    end
  end
end