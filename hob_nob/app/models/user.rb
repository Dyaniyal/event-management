class User < ActiveRecord::Base
  include AASM
  attr_accessor :role_type, :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :event_theme
  rolify

  devise :database_authenticatable, :registerable, 
         :recoverable, :rememberable, :trackable, :validatable#, :confirmable

  belongs_to :parent, :class_name => 'User', :foreign_key => 'licensee_id'
  has_and_belongs_to_many :clients
  has_and_belongs_to_many :events
  has_one :conversation
  has_one :user_poll
  has_one :user_feedback
  has_one :smtp_setting
  has_many :childrens, :class_name => 'User', :foreign_key => 'licensee_id'
  #belongs_to :client
  has_many :created_themes, :foreign_key => :created_by, :class_name => 'Theme'
  has_many :notifications, as: :resourceable
  has_many :faqs
  has_many :devices
  has_many :log_changes
  has_many :licensee_clients, :foreign_key => :licensee_id, :class_name => 'Client'
  has_many :icon_libraries, :class_name => 'IconLibrary', :foreign_key => 'licensee_id'
  has_many :telecaller_groups
  accepts_nested_attributes_for :telecaller_groups
  has_attached_file :licensee_logo, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(LICENSEE_IMAGE_PATH)
  validates_attachment_content_type :licensee_logo, :content_type => ["image/png"],:message => "please select valid format."

  serialize :assign_grouping, Array
  validates :company, :presence => true, :if => :license?
  validates :first_name, :last_name, presence:{ :message => "This field is required." }
  validate :check_grouping_is_preseent
  #validates :client_id, :presence => true, :unless => :license?
  validates :email,
             :presence =>true,
             :uniqueness => true,
             :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
             :message => "This field is required." }

  #validates :email, uniqueness: {scope: [:licensee_id]}
  validate :check_email_id_is_changed, :if => :license?
  validate :start_licensee_date_is_not_after_end_date   
  validate :image_dimensions
  validate :check_licensee_activate_option

  before_create :ensure_authentication_token, :generate_key
  # before_save :set_time
  before_validation :set_password_to_licensee, on: :create
  before_validation :set_status_to_licensee, on: :create
  after_save :check_status
  #after_save :change_status_for_super_admin
  
  aasm :column => :status do 
    state :pending, :initial => true
    state :active
    state :deactive
    state :rejected
   
    event :approve, :after => [:add_licensee_role] do
      transitions :from => [:pending, :rejected], :to => [:active]
    end
    event :reject do
      transitions :from => [:pending], :to => [:rejected]
    end 
    event :deactive do
      transitions :from => [:active], :to => [:deactive]
    end
    event :active do
      transitions :from => [:deactive], :to => [:active]
    end
  end 

  default_scope { order('created_at desc') }
  scope :check_deleted_record, -> { where('deleted != ?', 'true') }
  serialize :assign_grouping, Array

  def check_licensee_activate_option
    if self.license.present? and self.license == true
      if self.activate_mobile_app.blank?
        errors.add(:activate_mobile_app, "This field is required.")
      end
      if self.activate_ems.blank?
        errors.add(:activate_ems, "This field is required.")
      end
    end  
  end  

  def active_for_authentication?
    if self.telecaller == "true"
      super and self.telecaller_status?
    elsif self.has_role? :super_admin
      self.get_super_admin  
    else
      licensee_admin = self.get_licensee_admin
      super and licensee_admin.active? rescue nil
    end
  end

  def get_super_admin
    User.where(:id => self.id).first
  end 

  # below method for telecaller if telecaller telecaller.telecaller_status = "active" otherwise user not logged in
  def telecaller_status?
   if self.telecaller_status == "active"
     return true
   else
     return false
   end
  end
  ####################################
  def get_licensee_admin
    if self.has_role? :licensee_admin
      User.where(:id => self.id).first
    else
      User.where(:id => self.licensee_id).first
      # User.where(:licensee_id => self.licensee_id).first #ToDeactivate Every User which Belongs To Licensee User Created By Admin
    end
  end
  
  def check_status
    if self.has_role? :licensee_admin and self.licensee_end_date.present? and self.licensee_end_date > Date.today and self.status == "deactive"
      self.update_column(:status, "active")
    end
  end

  def self.change_status_for_super_admin
    users = User.with_role(:licensee_admin)
    users = users.where("license = ? AND status = ? AND (licensee_start_date > ? OR licensee_end_date < ?)", true, "active", Date.today, Date.today)
    users.each do |user|
      user.update_column(:status, "deactive")
    end
  end

  def self.current
    Thread.current[:user]
  end

  def self.current=(user)
    Thread.current[:user] = user
  end

  def add_licensee_role
    if self.license == true
      self.add_role :licensee_admin
    end
  end
 
  def generate_key
    self.key = Digest::SHA1.hexdigest(BCrypt::Engine.generate_salt)
    self.assign_secret_key
  end

  def assign_secret_key
    self.secret_key = self.get_secret_key
  end

  def assign_role_to_user(role, resource=nil)
    self.add_role role
    self.add_role role, resource if resource.present?
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = self.generate_authentication_token
    end
  end

  def set_password_to_licensee
    if self.password.blank? and self.license == true
      pass=self.email.first(4)
      pass+= rand.to_s[2..5]
      self.password = pass
    end
  end

  def set_status_to_licensee
    if self.license == true
      self.status = "pending"
    end
  end

  def change_status_for_super_admin
    if self.license == true
      self.perform_event('approve')
    end
  end

  def get_secret_key
    Digest::SHA1.hexdigest(self.email.to_s + self.encrypted_password.to_s + self.key)
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end  

  def push_notifications(msg, push_page, page_id)
    b_count = get_badge_count
    ios_tokens = devices.where(platform: 'ios').pluck(:token)
    android_tokens = devices.where(platform: 'android').pluck(:token)
    data = { page: push_page, page_id: page_id, title: 'Shobiz', badge: b_count, sound: 'siren.aiff', action: 'Read' }
    options = data.merge(message: msg)
    { android_push_response: android_tokens, ios_push_response: ios_tokens }.each do |response_type, tokens|
      options.merge!(notification: data.merge(body: msg)) if response_type == :ios_push_response
      response = Fcm_obj.send(tokens, options)
    end
  end

  def get_badge_count
    b_count = self.badge_count + 1 rescue 1
    self.update_column(:badge_count, b_count)
    b_count
  end


  def self.search(params, users, user_type)
    # list = User.where(users.paginate(:page => params[:page_no])
      package_type, first_name, email, status = params[:search][:package_type], params[:search][:first_name], params[:search][:email], status = params[:search][:status]
      keyword = params[:search][:keyword]
      users = users.where("first_name like ?", "%#{first_name}%") if first_name.present? and params[:adv_search].present?
      users = users.where("email like ?", "%#{email}%") if email.present? and params[:adv_search].present?
      users = users.where("package_type = ?", package_type) if package_type.present? and params[:adv_search].present?
      users = users.where("status = ?", status) if status.present? and params[:adv_search].present?
      users = users.where("first_name like ? or email like ?", "%#{keyword}%", "%#{keyword}%") if keyword.present?
    users
  end 

  def get_licensee_users
    if self.has_role? :licensee_admin
      User.where(:licensee_id => self.id)
    else
      User.where(:licensee_id => self.licensee_id)
    end
  end

  def get_licensee_admin
    if self.has_role? :licensee_admin
      User.where(:id => self.id).first
    elsif self.has_any_role?(:response_manager, :client_admin, :event_admin)
      User.where(:id => self.licensee_id).first
    else
      User.where(:licensee_id => self.licensee_id).first
    end
  end

  def get_licensee
    if self.has_role? :super_admin
      nil
    elsif self.has_role? :licensee_admin
      self.id
    else
      self.licensee_id
    end
  end

  def get_smtp_setting
    licensee_admin = get_licensee_admin
    smtp_setting = licensee_admin.smtp_setting rescue nil
  end

  def perform_event(status)
    self.approve! if status== "approve"
    self.reject! if status== "reject"
    self.deactive! if status== "deactive"
    self.active! if status== "active"
  end

  def check_email_id_is_changed
    if self.id and self.email_changed?
      self.email = User.find(self.id).email
      self.errors.add(:email,'You cant change the email_id of this user')
    end
  end

  def name_with_email
    users = []
    self.get_licensee_users.each do |user|
      if user.last_name.present?
        users << "#{user.first_name.to_s + " " + user.last_name.to_s}(#{user.email})"
      else
        users << "#{user.first_name}(#{user.email})"
      end
    end
    users
  end

  def telecaller_list
    users = []
    user_list = self.get_licensee_users.where(:telecaller=>"true")
    user_list.each do |user|
      if user.last_name.present?
        users << "#{user.first_name.to_s + " " + user.last_name.to_s}(#{user.email})"
      else
        users << "#{user.first_name}(#{user.email})"
      end
    end
    users
  end 

  def is_super_admin?
    self.has_role? :super_admin
  end

  def self.get_users_based_on_resource(resource)
    User.joins(:roles).where("resource_id = ? and resource_type = ?", resource.id, resource.class.name)
  end

  def get_role_on_resource(resource)
    Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', resource.class.name, resource.id, self.id).last
  end

  def self.get_managed_user(user,client_ids,event_ids,session_role)
    if user.has_role_without_event("licensee_admin", client_ids,session_role)#user.has_role? :licensee_admin
      role = Role.where(:resource_type => nil, :resource_id => nil, :name => 'licensee_admin').first
      users = User.where(:licensee_id => user.id)
      users
    else
      users = []
      if user.has_role_without_event("client_admin", client_ids,session_role)#user.has_role? :client_admin
        users = User.joins(:roles).where('roles.resource_type = ? and resource_id IN(?) and roles.name NOT IN (?)', "Event", event_ids, Role.not_manage_user_dropdown("client_admin")).uniq
      elsif user.has_role_without_event("event_admin", client_ids,session_role)#user.has_role? :event_admin
        users = User.joins(:roles).where('roles.resource_type = ? and resource_id IN(?) and roles.name NOT IN (?)', "Event", event_ids, Role.not_manage_user_dropdown("event_admin")).uniq
      end  
      #users = User.joins(:roles).where('roles.resource_type = ? and resource_id IN(?) and roles.name NOT IN (?)', "Client", client_ids, Role.not_manage_user_dropdown("client_admin")).uniq rescue nil
      #users += User.joins(:roles).where('roles.resource_type = ? and resource_id IN(?) and roles.name NOT IN (?)', "Event", event_ids, Role.not_manage_user_dropdown("event_admin")).uniq
      users
    end
  end
  
  # def set_time
  #   self.licensee_start_date ="#{self.licensee_start_date.strftime("%Y/%m/%d")} #{self.start_time_hour}:#{self.start_time_minute}:00 #{self.start_time_am}".to_time rescue nil
  #   self.licensee_end_date ="#{self.licensee_end_date.strftime("%Y/%m/%d")} #{self.end_time_hour}:#{self.end_time_minute}:00 #{self.end_time_am}".to_time rescue nil
  # end

  def check_currect_password(data)
    errors.add(:current_password, "This field is required.") if data[:current_password].blank?
    errors.add(:password, "This field is required.") if data[:password].blank?
    errors.add(:password_confirmation, "This field is required.") if data[:password_confirmation].blank?
    (data[:password_confirmation].blank? or data[:password].blank? or data[:current_password].blank?) ? false : true
  end

  def start_licensee_date_is_not_after_end_date
    return if self.licensee_start_date.blank? || self.licensee_end_date.blank? 
    if self.licensee_start_date.present? and self.licensee_end_date.present? 
      if self.licensee_end_date <= self.licensee_start_date
        errors.add(:licensee_end_date, "cannot be before the start date")
      end
    end
  end

  def image_dimensions
    if self.licensee_logo_file_name_changed?  
      licensee_logo_dimension_height  = 50.0
      licensee_logo_dimension_width = 250.0
      dimensions = Paperclip::Geometry.from_file(licensee_logo.queued_for_write[:original].path)
      if (dimensions.width < licensee_logo_dimension_width or dimensions.height < licensee_logo_dimension_height )
        errors.add(:licensee_logo, "Image size should be 250x50px only")
      else
        self.errors.delete(:licensee_logo)
      end
    end
  end

  def get_full_name
    self.first_name.to_s + " " + self.last_name.to_s
  end

  def self.get_user_by_id(user_id)
    User.find_by_id(user_id)
  end

  def add_role_to_telecaller(telecaller,event)
    if telecaller.telecaller == "true"
      telecaller.add_role :telecaller
      telecaller.add_role :telecaller,event
    end
  end

  def check_grouping_is_preseent
    # if self.assign_grouping.blank? and self.telecaller.present?
    #   errors.add(:assign_grouping, "This field is required.")
    # end
    # if self.target_assigned.blank? and self.telecaller.present?
    #    errors.add(:target_assigned, "This field is required.")
    # end
    # if self.registration_target.blank? and self.telecaller.present?
    #  errors.add(:registration_target, "This field is required.")
    # end
    if self.password_confirmation.blank? and self.telecaller.present? and self.new_record?
      errors.add(:password_confirmation, "This field is required.")
    end
  end

  def has_role_for_event?(role_name, event_id, session_role_name)
    roles = self.roles
    access = false
    for role in roles 
      if role.resource_type == "Event"
        access = true if role.name == role_name and role.name == session_role_name and role.resource_id == event_id.to_i
      elsif role.resource_type == "Client"
        access = true if role.resource.events.pluck(:id).include? event_id.to_i and role.name == role_name and role.name == session_role_name
      end
      return true if access 
    end
    access
  end

  # def has_role_without_event(role_name, client_ids,session_role_name)
  #   # clients = Client.where(:id => client_ids)
  #   event_ids = Event.where(:client_id => client_ids).pluck(:id)
  #   access = false
  #   roles = self.roles
  #   for client_id in client_ids
  #     events = Event.where(:client_id => client_id)#client.events
  #     for event in events
  #       for role in roles 
  #         if role.resource_type == "Event"
  #           access = true if role.name == role_name and role.name == session_role_name and role.resource_id == event.id
  #         elsif role.resource_type == "Client"
  #           access = true if role.resource.events.pluck(:id).include? event.id and role.name == role_name and role.name == session_role_name
  #         end
  #         return true if access 
  #       end
  #     end
  #   end
  #   access
  # end

  def has_role_without_event(role_name, client_ids,session_role_name)
    event_ids = Event.where(:client_id => client_ids).pluck(:id)
    access = false
    for role in self.roles 
      if role.resource_type == "Event"
        access = true if role.name == role_name and role.name == session_role_name and event_ids.include? role.resource_id 
      elsif role.resource_type == "Client"
        access = true if (role.resource.events.pluck(:id) & event_ids).present? and role.name == role_name and role.name == session_role_name
      # added for those licensee have activate mobile app option no and first time creating events
      elsif self.license and session_role_name == "licensee_admin" and event_ids.blank? and client_ids.blank?
        access = true if role.name == role_name and role.name == session_role_name
      end
      return true if access 
    end
    access
  end

  def has_role_client_db_manager_landing_page_dashbord(role_name, client_ids,session_role_name)
    event_ids = Event.where(:client_id => client_ids).pluck(:id)
    access = false
    for role in self.roles 
      if role.resource_type == "Client"
        access = true if (role.resource.events.pluck(:id) & event_ids).present? and role.name == role_name and role.name == session_role_name
      end
      return true if access 
    end
    access
  end

  def get_roles_for_user_for_checking(user,resource_id,user_id)
    @roles = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', user, resource_id, user_id).pluck(:name)
  end  
  
  def get_clients
    clients = Client.with_roles(self.roles.pluck(:name), self)
  end
  
  def get_roles_for_user(user,resource_id,user_id)
    @roles = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', user, resource_id, user_id).pluck(:name).map{|n| n.humanize}.join(', ')
  end

  def get_licensee_events_count
    clients = get_clients
    event_count = clients.map{|c| c.events.where(:marketing_app=>nil).count}.sum
  end

  # def get_count(telecaller_id,event_id, type)
  #   event = Event.find(event_id)
  #   telecaller = User.unscoped.find(telecaller_id)
  #   #grouping = Grouping.find(telecaller.assign_grouping)# rescue nil
  #   grouping = Grouping.where("id IN (?)",telecaller.assign_grouping) rescue nil

  #   groupings = Grouping.with_role(telecaller.roles.pluck(:name), telecaller)
  #   invitee_structure = event.invitee_structures.first if event.invitee_structures.present?
  #   invitee_data = invitee_structure.invitee_datum
  #   @data = Grouping.get_multiple_group_data_count(invitee_data, [grouping]) if groupings.present? and invitee_data.present?
  #   #@data = Grouping.get_search_data_count(invitee_data, [grouping]) if groupings.present? and invitee_data.present?
  #   @assigned = @data.present? ? @data.count : 0
  #   @processed = @data.present? ? @data.where('status IS NOT NULL').count : 0
  #   @remaining = @data.present? ? @data.where(:status => nil).count : 0
  #   return @assigned if type == "Assigned"
  #   return @processed if type == "Processed"
  #   return @remaining if type == "Remaining"
  # end

  def get_count(telecaller_id,event_id, type)
    event = Event.find(event_id)
    telecaller = User.unscoped.find(telecaller_id)
    #grouping = Grouping.find(telecaller.assign_grouping)# rescue nil
    @telecaller_group = TelecallerGroup.where(:user_id=>telecaller_id,:event_id=>event_id).first rescue nil
    grouping = Grouping.where("id IN (?)",@telecaller_group.assign_grouping) rescue nil
    #grouping = Grouping.where("id IN (?)",telecaller.assign_grouping) rescue nil

    groupings = Grouping.with_role(telecaller.roles.pluck(:name), telecaller)
    invitee_structure = event.invitee_structures.first if event.invitee_structures.present?
    invitee_data = invitee_structure.invitee_datum
    @data = Grouping.get_multiple_group_data_count(invitee_data, [grouping]) if groupings.present? and invitee_data.present?
    #@data = Grouping.get_search_data_count(invitee_data, [grouping]) if groupings.present? and invitee_data.present?
    unless event.telecaller_accessible_columns.first.allow_unsubscribers?
      unsub_emails = Unsubscribe.unsub_emails(event)
      @data = @data.where.not(attr1: unsub_emails)
    end
    @assigned = @data.present? ? @data.count : 0
    @processed = @data.present? ? @data.where('status IS NOT NULL').count : 0
    @remaining = @data.present? ? @data.where(:status => nil).count : 0
    return @assigned if type == "Assigned"
    return @processed if type == "Processed"
    return @remaining if type == "Remaining"
  end

  def telecaller_report_count(telecaller_id,event, type,date1=nil,date2=nil)
    telecaller = User.unscoped.find(telecaller_id)
    telecaller_group = telecaller.telecaller_groups.where(:event_id=>event.id).first
    grouping = Grouping.where( "id IN (?)",telecaller_group.assign_grouping) if telecaller_group.present?
    groupings = Grouping.with_role(telecaller.roles.pluck(:name), telecaller)
    invitee_structure = event.invitee_structures.first if event.invitee_structures.present?
    invitee_data = invitee_structure.invitee_datum.exclude_unsubcribes(event)
    @data = Grouping.get_multiple_group_data_count(invitee_data, [grouping]) if groupings.present? and invitee_data.present?
    if type == "not_called"
      @no_called = @data.where(status: nil, invitee_data_updated: nil) if @data.present?
    end  
    if date1.present? and date1 == "last 7 days"
      @assigned = @data.where("status is not null and Date(invitee_data_updated) > ?",(Date.today - 7)) if @data.present? and type == "Assigned"
      @registered = @data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","REGISTERED",(Date.today - 7)) if @data.present? and type == "REGISTERED"
      @hot_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","HOT",(Date.today - 7)) if @data.present? and type == "HOT"          
      @warm_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","WARM",(Date.today - 7)) if @data.present? and type == "WARM"
      @regret_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","REGRET",(Date.today - 7)) if @data.present? and type == "REGRET"
      @other_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","OTHER",(Date.today - 7)) if @data.present? and type == "OTHER"
      @reopened_invitee_datum = @data.where("status IS NULL and Date(invitee_data_updated) > ?", Date.today - 7) if @data.present? and type == "REOPEN"
    elsif date1.present? and date2.present?
      @assigned = @data.where("status is not null and  Date(invitee_data_updated) BETWEEN  ? AND ?",date1.to_date,date2.to_date) if @data.present? and type == "Assigned"
      @registered = @data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","REGISTERED",date1.to_date,date2.to_date) if @data.present? and type == "REGISTERED"
      @hot_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","HOT",date1.to_date,date2.to_date) if @data.present? and type == "HOT"
      @warm_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","WARM",date1.to_date,date2.to_date) if @data.present? and type == "WARM"
      @regret_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","REGRET",date1.to_date,date2.to_date) if @data.present? and type == "REGRET"
      @other_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","OTHER",date1.to_date,date2.to_date) if @data.present? and type == "OTHER"
      @reopened_invitee_datum = @data.where("status IS NULL and Date(invitee_data_updated) BETWEEN  ? AND ?",date1.to_date,date2.to_date) if @data.present? and type == "REOPEN"
    else
      @assigned = @data.where("status is not null and Date(invitee_data_updated) = ?",Date.today) if @data.present? if type == "Assigned"
      @registered = @data.where("reported_status IN (?) and Date(invitee_data_updated) = ?","REGISTERED",Date.today) if type == "REGISTERED" and @data.present?
      @hot_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) = ?","HOT",Date.today) if type == "HOT" and @data.present?
      @warm_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) = ?","WARM",Date.today) if type == "WARM" and @data.present?
      @regret_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) = ?","REGRET",Date.today) if type == "REGRET" and @data.present?
      @other_status = @data.where("reported_status IN (?) and Date(invitee_data_updated) = ?","OTHER",Date.today) if type == "OTHER" and @data.present?
      @reopened_invitee_datum = @data.where("status IS NULL and Date(invitee_data_updated) = ?", Date.today) if @data.present? and type == "REOPEN"
    end
    return @no_called if type == "not_called"
    return @assigned.where("telecaller_id =?", telecaller_id) if @assigned.present? and  type == "Assigned"
    return @registered.where("telecaller_id =?", telecaller_id) if @registered.present? and type == "REGISTERED"
    return @hot_status.where("telecaller_id =?", telecaller_id) if @hot_status.present? and type == "HOT"
    return @warm_status.where("telecaller_id =?", telecaller_id) if @warm_status.present? and type == "WARM"
    return @regret_status.where("telecaller_id =?", telecaller_id) if @regret_status.present? and type == "REGRET"
    return @other_status.where("telecaller_id =?", telecaller_id) if @other_status.present? and type == "OTHER"
    return @reopened_invitee_datum.where("telecaller_id =?", telecaller_id) if @reopened_invitee_datum.present? and type == "REOPEN"

  end

  #######
  def self.get_telecaller_assigned_data(event)
    TelecallerGroup.where(:event_id=>event.id).sum(:target_assigned)
    #User.joins(:roles).where('roles.resource_type = ? and resource_id = ? and roles.name = ?', "Event", event.id, "telecaller").telecaller_groups.sum(:target_assigned)
  end
  
  def self.registration_target_data(event)
    TelecallerGroup.where(:event_id=>event.id).sum(:registration_target)
  end
  
  def self.get_telecaller_achived_data(event,invitee_data,params)
    if params[:filter_date].blank? or (params[:filter_date].present? and params[:filter_date] == "today")
      @achieved_number = invitee_data.where("status is not null  and Date(invitee_data_updated) = ?",Date.today) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "last 7 days"
      @achieved_number = invitee_data.where("status is not null and Date(invitee_data_updated) > ?",(Date.today - 7)) if invitee_data.present? 
    elsif params[:filter_date].present? and params[:filter_date] == "date range"
      @achieved_number = invitee_data.where("status is not null  and Date(invitee_data_updated) BETWEEN  ? AND ?",params[:start_date].to_date,params[:end_date].to_date) if invitee_data.present?
    end
  end  

  def self.get_telecaller_registered_data(event,invitee_data,params)
    if params[:filter_date].blank? or (params[:filter_date].present? and params[:filter_date] == "today")
      @registerd_status = invitee_data.where('reported_status = ? and Date(invitee_data_updated) = ?',"REGISTERED",Date.today) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "last 7 days"
      @registerd_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","REGISTERED",(Date.today - 7)) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "date range"
      @registerd_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","REGISTERED",params[:start_date].to_date,params[:end_date].to_date) if invitee_data.present?
    end
  end  

  def self.get_telecaller_hot_data(event,invitee_data,params)
    if params[:filter_date].blank? or (params[:filter_date].present? and params[:filter_date] == "today")
      @hot_status = invitee_data.where('reported_status = ? and Date(invitee_data_updated) = ?',"HOT",Date.today) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "last 7 days"
      @hot_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","HOT",(Date.today - 7)) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "date range"
      @hot_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","HOT",params[:start_date].to_date,params[:end_date].to_date) if invitee_data.present?
    end
  end  

  def self.get_telecaller_warm_data(event,invitee_data,params)
    if params[:filter_date].blank? or (params[:filter_date].present? and params[:filter_date] == "today")
      @warm_status = invitee_data.where('reported_status = ? and Date(invitee_data_updated) = ?',"WARM",Date.today) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "last 7 days"
      @warm_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","WARM",(Date.today - 7)) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "date range"
      @warm_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","WARM",params[:start_date].to_date,params[:end_date].to_date) if invitee_data.present?  
    end
  end  
  
  def self.get_telecaller_regret_data(event,invitee_data,params)
    if params[:filter_date].blank? or (params[:filter_date].present? and params[:filter_date] == "today")
      @regret_status = invitee_data.where('reported_status = ? and Date(invitee_data_updated) = ?',"REGRET",Date.today) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "last 7 days"
      @regret_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","REGRET",(Date.today - 7)) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "date range"
      @regret_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","REGRET",params[:start_date].to_date,params[:end_date].to_date) if invitee_data.present?
    end
  end  

  def self.get_telecaller_other_data(event,invitee_data,params)
    if params[:filter_date].blank? or (params[:filter_date].present? and params[:filter_date] == "today")
      @regret_status = invitee_data.where('reported_status = ? and Date(invitee_data_updated) = ?',"OTHER",Date.today) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "last 7 days"
      @regret_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) > ?","OTHER",(Date.today - 7)) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "date range"
      @regret_status = invitee_data.where("reported_status IN (?) and Date(invitee_data_updated) BETWEEN  ? AND ?","OTHER",params[:start_date].to_date,params[:end_date].to_date) if invitee_data.present?
    end
  end  

  def self.get_reopened_data(event,invitee_data,params)
    if params[:filter_date].blank? or (params[:filter_date].present? and params[:filter_date] == "today")
      @regret_status = invitee_data.where('status IS NULL and Date(invitee_data_updated) = ?',Date.today) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "last 7 days"
      @regret_status = invitee_data.where("status IS NULL and Date(invitee_data_updated) > ?",(Date.today - 7)) if invitee_data.present?
    elsif params[:filter_date].present? and params[:filter_date] == "date range"
      @regret_status = invitee_data.where("status IS NULL and Date(invitee_data_updated) BETWEEN  ? AND ?",params[:start_date].to_date,params[:end_date].to_date) if invitee_data.present?
    end
  end    

  def self.get_callback_invitees(data, event, user_id = nil)
    data.where("status IN (?) and callback_datetime < ? and telecaller_id = ?",["CALL BACK - NO RESPONSE","FOLLOW UP", "WARM", "HOT"], (Time.now + 5.minutes + event.timezone_offset).to_formatted_s(:db), user_id) rescue []
  end

  def self.get_telecaller_assigned_records(event)
    data = []
    telecaller_group = TelecallerGroup.where(:event_id => event.id)
    grouping = Grouping.where( "id IN (?)", telecaller_group.pluck(:assign_grouping).flatten)# rescue nil
    invitee_structure = event.invitee_structures.first if event.invitee_structures.present?
    invitee_data = invitee_structure.invitee_datum.exclude_unsubcribes(event)
    data = Grouping.get_multiple_group_data_count(invitee_data, [grouping]) if invitee_data.present?
    data
  end
end