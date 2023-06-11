class InviteeDatum < ActiveRecord::Base
	belongs_to :invitee_structure

  attr_accessor :callback_time_hour, :callback_time_minute ,:callback_time_am,:callback_date,:check_remark_and_status_present, :skip_status_update, :is_updated, :is_new, :edm_selected
  validates :invitee_structure_id, :presence => true
  validates :attr1, uniqueness: {scope: :invitee_structure_id}
  # validates :attr1,:attr2,:attr3,:attr4,:attr5,:attr6,:attr7,:attr8,:attr9,:attr10,:attr11,:attr12,:attr13,:attr14,:attr15, presence:{ :message => "This field is required." }
  # validates :attr1,:attr2,:attr3,:attr4, presence:{ :message => "This field is required." }, :if => Proc.new{|p| p.check_remark_and_status_present == "true"}
  #validates :attr1,:attr2,:attr3,:attr4,:attr6,:attr11,:attr12, presence:{ :message => "This field is required." }, :if => Proc.new{|p| p.check_remark_and_status_present == "true"}
  # validates :callback_date, presence:{ :message => "This field is required." }, :on => :update, :if => Proc.new{|p| p.status == "CALL BACK" || p.status == "FOLLOW UP"}
  validates :callback_date, presence:{ :message => "This field is required." }, :on => :update, :if => Proc.new{|p| p.status == "WARM" || p.status == "FOLLOW UP" || p.status == "HOT" and p.skip_status_update != "true"}
  validates :status, :reported_status, :remark, presence:{ :message => "This field is required." }, :on => :update, :if => Proc.new{|p| p.skip_status_update != "true"}

  #validates :status, :remark, presence:{ :message => "This field is required." }, :on => :update, :if => Proc.new{|p| p.skip_status_update != "true"}
  validate :validate_uniq_identifier, :data_import
  # validate :set_callback_time_and_date
  validate :call_back_previous_date_time, :if => Proc.new{|p| p.skip_status_update != "true"}
  validate :edm_presence, if: Proc.new { |p| p.status == 'SEND EMAIL' }

  validates :attr1,
            :format => {
            :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9_]+\.)+[a-z0-9_]{2,}\z/i,
            :message => "Sorry, this doesn't look like a valid email." },
            :if => Proc.new{|i| i.attr1.present?}
  after_save :update_registration_status
  after_save :update_opt_for_unsubscribe

  scope :exclude_unsubcribes, -> (event) { where.not(attr1: Unsubscribe.unsub_emails(event)) unless event.reload.telecaller_accessible_columns.first.try(:allow_unsubscribers) }

  default_scope { order('created_at desc') }

  def edm_presence
    event = invitee_structure.event
    edms = Edm.where(telecaller_assigned: true, event_id: event.id)
    if edm_selected.blank?
      errors.add(:edm_selected, 'Select eDM to Send.')
    end
  end

  def update_opt_for_unsubscribe
    email_field = self.attr1
    event = self.invitee_structure.event
    unsubscribed_email = Unsubscribe.where(:event_id => event.id, :email => email_field).first rescue nil
    if unsubscribed_email.present? and unsubscribed_email.unsubscribe == "true"
      self.update_column(:opt_unsubscribe, true)
    end
  end
  
  def update_registration_status
    email_address = self.attr1
    event = self.invitee_structure.event
    email_field = event.registrations.first.email_field if event.registrations.present?
    if email_field.present?
      user_registrations = event.user_registrations.where("#{email_field} LIKE '%#{email_address}%'")
      status = user_registrations.first.status if user_registrations.first.present?
    end
    if status.present?
      self.update_column(:registration_status, status)
      self.update_column(:telecaller_update_count, self.telecaller_update_count.to_i + 1)
    end
  end

  def call_back_previous_date_time
    if ["CALL BACK - NO RESPONSE", "FOLLOW UP", "HOT", "WARM"].include? self.status
      errors.add(:callback_date, "Date/time must be greater than current time.") if self.callback_datetime.present? and ((self.callback_datetime).to_formatted_s(:db) < (Time.now + self.invitee_structure.event.timezone_offset).to_datetime)
    end
  end

  def validate_uniq_identifier
  	if self.invitee_structure.present?
  		identifier = self.invitee_structure.uniq_identifier
      if !(self.attribute_present? (identifier))
        self.errors.add identifier, 'This field is required.'
      end
  	end
  end

  def method_missing method_name, *args
    attr_value = self.invitee_structure.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier','multi_lng_parent_id','language_updated').map{|k, v| v.to_s.length > 0 && v.downcase == method_name.to_s ? v.downcase : nil}.compact!
    attr_value
  end

  def set_status_and_remark_as_mandetory(params)
    if params[:invitee_datum][:status].present?
      self.update_column(:status,params[:invitee_datum][:status]) if params[:invitee_datum][:remark].present?
    else 
      errors.add(:status, "This field is required.") 
    end
    if params[:invitee_datum][:remark].present?
      self.update_column(:remark,params[:invitee_datum][:remark]) if params[:invitee_datum][:status].present?
    else
      errors.add(:remark, "This field is required.") if params[:remark].blank?
    end
  end

  def set_time(callback_date, callback_time_hour, callback_time_minute, callback_time_am)
    callback = "#{callback_date} #{callback_time_hour.gsub(':', "") rescue nil}:#{callback_time_minute.gsub(':', "") rescue nil}:#{0} #{callback_time_am}"
    callback = callback.to_datetime rescue nil
    self.callback_datetime = callback  if callback_date.present?
  end

  def check_callback_time_and_date(invitee_datum)
    if invitee_datum[:status] == "CALL BACK - NO RESPONSE" or invitee_datum[:status] == "Follow up"
      errors.add(:callback_date, "This field is required.") if invitee_datum[:callback_date].blank? 
    end
  end

  def data_import
    if self.check_remark_and_status_present.present?
      @event = self.invitee_structure.event
      acessible_column = []
      mandate_db = []
      @event.telecaller_accessible_columns.first.accessible_attribute.map{|k,v|acessible_column << k}
      @event.invitee_structures.first.attributes.except('id', 'created_at', 'updated_at', 'event_id', 'uniq_identifier', 'email_field','parent_id','attr1','attr2','attr3','attr4','attr5','attr6','attr7','attr8','attr9','attr10','attr11','ttr12','attr13','attr14','attr15','attr16','attr17','attr18','attr19','attr20', 'attr21','attr22','attr23','attr24','attr25','attr26','attr27','attr28','attr29','attr30','attr31','attr32','attr33','attr34','attr35','attr36','attr37','attr38','attr39','attr40','attr41','attr42','attr43','attr44','attr45','attr46','attr47','attr48','attr49','attr50').map{|k, v| v.to_s.length > 0  and v.to_s =="yes"? mandate_db << k.downcase : nil}.compact
      mandate_db_fields = mandate_db.map{ |a|a.gsub("mandate_","")}
      validate_fields = acessible_column & mandate_db_fields
      validate_fields.each do |data|
        errors.add("#{data}", "This field is required.") if self.send("#{data}").blank?  
      end
    else
      invitee_structure = InviteeStructure.find(self.invitee_structure_id).attributes.except('id','attr1','attr2','attr3','attr4','attr5','attr6','attr7','attr8','attr9','attr10','attr11','attr12','attr13','attr14','attr15','attr16','attr17','attr18','attr19','attr20','attr21','attr22','attr23','attr24','attr25','attr26','attr27','attr28','attr29','attr30','attr31','attr32','attr33','attr34','attr35','attr36','attr37','attr38','attr39','attr40','attr41','attr42','attr43','attr44','attr45','attr46','attr47','attr48','attr49','attr50',"parent_id","created_at","updated_at")
      invitee_structure_data = InviteeStructure.find(self.invitee_structure_id)
      invitee_data = self.attributes.except('id','invitee_structure_id',"status","remark","callback_datetime","telecaller_id","created_at","updated_at",'attr1')
      invitee_data.each do |data|
        if invitee_structure.include?("mandate_#{data[0]}") and invitee_structure["mandate_#{data[0]}"] == "yes" and data[1].blank? and invitee_structure_data[data[0]].present?
          errors.add("#{data[0]}", "This field is required.")
        end
      end
    end
  end


  def self.telecaller_data(event)
    @source = event
    @users = User.joins(:roles).where('roles.resource_type = ? and resource_id = ? and roles.name NOT IN (?)', @source.class.name, @source.id, ['licensee_admin', 'client_admin', 'event_admin', 'moderator', 'db_manager']).uniq
    @data = []
    for user in @users
      #@grouping = Grouping.find_by_id(user.assign_grouping) 
      @grouping = Grouping.where("id IN (?)",user.assign_grouping)
      @groupings = Grouping.with_role(user.roles.pluck(:name), user)
      @invitee_structure = event.invitee_structures.first if event.invitee_structures.present?
      @invitee_data = @invitee_structure.invitee_datum
      data = Grouping.get_data_count_for_db(@invitee_data, @grouping) if @groupings.present? and @invitee_data.present?
      @data << data
    end
    return @data
  end

  def self.get_updated_data_count(event)
    data = event.invitee_structures.first.present? ? event.invitee_structures.first.invitee_datum : []
    if data.present?
      regi_data_updated_count = data.map{|d| d.registration_update_count.present? ? d.registration_update_count : nil}.compact
      tele_data_updated_count = data.map{|d| d.telecaller_update_count.present? ? d.telecaller_update_count : nil}.compact
      total_data = (regi_data_updated_count + tele_data_updated_count)
      data_updated_count = total_data.inject() { |sum, number| sum.to_i + number.to_i }  if total_data.present?
    end 
  end

  def get_telecaller_name
    user = User.where("id IN (?)",self.telecaller_id)
    if user.present?
      user.first.first_name.to_s + " " + user.first.last_name.to_s
    else
      ""
    end  
  end  

  def self.get_invitee_data_as_per_group(event_id,group_id)
    if group_id.present? and event_id.present?
      event = Event.find_by_id(event_id)
      grouping = Grouping.where(:event_id => event_id, :id => group_id).last
      invitee_structure = event.invitee_structures.last
      columns = invitee_structure.attributes.except('id','created_at','updated_at','event_id','uniq_identifier','parent_id','email_field')
      only_columns = invitee_structure.get_selected_column
      invitee_datum = grouping.get_search_data_count(InviteeDatum.where(:invitee_structure_id => invitee_structure.id))
    end
  end

end
