class MobileApplication < ActiveRecord::Base
  include AASM
  require 'review_status'
  resourcify
  serialize :preferences
  USER_ENGAGEMENT = ['Conversation', 'Favorite', 'Rating', 'Q&A', 'Poll', 'Feedback', 'E-Kit', 'QR code scan', 'Quiz']

  ['USER_ENGAGEMENT_FEATURE', 'CARD_IMAGES', 'BREADCRUM_IMAGES'].each do |const|
    const_set(
      const,
      HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("#{Rails.root}/config/mobile_application.yml", __FILE__))))[const.downcase]
    )
  end

  BREADCRUM_IMAGES = {"themes" => "themes_breadcumb.png","event_features"=>"feature-breadcumb.png","notifications" => "notification-breadcumb.png", "event_highlights"=>"event_highlights-breadcumb.png","highlight_images"=>"gallery.png","contacts"=>"contact_us-breadcumb.png","emergency_exits"=>"venue-breadcumb.png", "abouts" => "about-breadcumb.png", "speakers" => "speakers-breadcumb.png", "agendas" => "agenda-breadcumb.png", "invitees" => "invitees-breadcumb.png", "awards" => "awards_2-breadcumb.png", "polls" => "polls_1-breadcumb.png", "conversations" => "conversations_breadcumb.png", "faqs" => "faq-breadcumb.png", "e_kits" => "e-kit-breadcumb.png", "qnas" => "Q&A-breadcumb.png", "feedbacks" => "feedback-breadcumb.png", "images" => "galler_1y-breadcumb.png", "mobile_applications" => "mobile-app-breadcumb.png", "winners" => "winner-breadcumb.png", "panels" => "panel_1-breadcumb.png", "dashboards" => "dashboard.png", "events" => "event-breadcumb.png", "clients" => "client-breadcumb.png", "users" => "user_3-breadcumb.png", "licensees" => "licensee_breadcumb.png", "imports" => "invitees-breadcumb.png", "push_pem_files" => "user-permission_breadcumb.png", "store_infos" => "mobile-app-breadcumb.png", "menus" => "menu-breadcumb.png","sponsors" => "sponsor-breadcumb.png", "invitee_structures" => "database-breadcumb.png","registrations"=>"registration-breadcumb.png", "profiles" => "my_profile_breadcumb.png", "quizzes" =>"polls_breadcumb.png", "exhibitors" => "Exhibitor-breadcumb.png", "manage_mobile_apps" => "mobile-app-breadcumb.png", "custom_page1s" => "custom.png", "custom_page2s" => "custom.png", "custom_page3s" => "custom.png", "custom_page4s" => "custom.png", "custom_page5s" => "custom.png","custom_page6s" => "custom.png", "custom_page7s" => "custom.png", "custom_page8s" => "custom.png", "custom_page9s" => "custom.png", "custom_page10s" => "custom.png","registration_settings" => "registration-setting.png","telecallers" => "telecaller.png","invitee_datas" => "telecaller.png","groupings" => "database.png","user_registrations"=>"registration.png","my_travels" => "travel.png","smtp_settings"=>"smtp_setting.png","manage_invitee_fields"=>"manage_invitee.png", "qna_walls"=>"settings.png", "conversation_walls" =>"settings.png", "quiz_walls"=>"settings.png","poll_walls"=>"settings.png", 'activity_feeds' => 'activity_feed.png','qna_settings' =>"Q&A-breadcumb.png", 'icon_libraries' => 'Library.png',"telecaller_dashboards" => "telecaller.png","invitee_groups" => "notification-breadcumb.png","edms" => "edm.png","campaigns" => "campaign.png","maps" => "map.png", "microsite_features" => "feature-breadcumb.png","microsites" => "microsite.png","microsite_menus" => "menu-breadcumb.png","microsite_look_and_feels" => "themes.png", "import_data_api" => "database-breadcumb.png","registration_look_and_feels" => "themes.png","feedback_forms" => "feedback-breadcumb.png","track_link_users" => "edm.png", "consent_questions" => "settings.png", "mobile_consent_questions" => "settings.png", "consent_question_look_and_feels" => "themes.png", 'fonts' => 'edit.png' }
  # attr_accessor :template_id
  
  belongs_to :client
  has_one :push_pem_file, :dependent => :destroy
  has_one :store_info
  has_many :events
  has_many :mobile_consent_questions, :dependent => :destroy
  has_one :consent_question_look_and_feel, :dependent => :destroy
  accepts_nested_attributes_for :events

  after_save :update_client_id
  after_create :set_preview_submitted_code, :new_mobileapp_set_push_fcm
  after_save :update_social_media_status

  has_attached_file :app_icon, {:styles => {:large => "90x90>",
                                         :small => "60x60>", 
                                         :thumb => "54x54>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_APP_ICON_PATH)
  
  has_attached_file :splash_screen, {:styles => {:large => "1024x2208>",
                                         :small => "600x600>", 
                                         :thumb => "200x200>"},
                             :convert_options => {:large => "-strip -quality 80", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_SPLASH_SCREEN_PATH)

  has_attached_file :login_background, {:styles => {:large => "1024x2208>",
                                         :small => "600x600>", 
                                         :thumb => "200x200>"},
                             :convert_options => {:large => "-strip -quality 80", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_LOGIN_BACKGROUND_PATH)

  has_attached_file :listing_screen_background, {:styles => {:large => "1024x2208>",
                                         :small => "600x600>", 
                                         :thumb => "200x200>"},
                             :convert_options => {:large => "-strip -quality 80", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_LISTING_SCREEN_BACKGROUND_PATH)

  has_attached_file :visitor_registration_background_image, {:styles => {:large => "90x90>",
                                         :small => "60x60>", 
                                         :thumb => "54x54>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Mobile_Application_VISITOR_REGISTRATION_IMAGE_PATH)

  validates_attachment_content_type :app_icon,:content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :splash_screen, :content_type => ["image/png"],:message => "please select valid format."
  validates :name, :application_type, :listing_screen_text_color, :visitor_registration,:agreeing_terms_and_conditions,presence: { :message => "This field is required." }
  validate :listing_screen_text_color_presentce,:check_privacy_policy_value_present
  validates :name, uniqueness: {scope: :client_id}
  validates :social_media_logins, presence: { :message => "This field is required." },:if => Proc.new{|p| p.social_media_status.present? and p.social_media_status == "active" and p.social_media_logins.blank?}
  
  validate :image_dimensions_for_app_icon, :if => Proc.new{|p| p.app_icon_file_name_changed? and p.app_icon_file_name.present? and p.parent_id.blank?}
  validate :image_dimensions_for_splash_screen, :if => Proc.new{|p| p.splash_screen_file_name_changed? and p.splash_screen_file_name.present? and p.parent_id.blank?}
  validate :image_dimensions_for_login_background, :if => Proc.new{|p| p.login_background_file_name_changed? and p.login_background_file_name.present? and p.parent_id.blank?}
  validate :image_dimensions_for_screen_background, :if => Proc.new{|p| p.listing_screen_background_file_name_changed? and p.listing_screen_background_file_name.present? and p.parent_id.blank?}
  validate :registration_background_image_or_color_present, :if => Proc.new{|p| p.visitor_registration == "yes" and p.visitor_registration_background_image_file_name.blank? and p.visitor_registration_background_color.blank? and p.parent_id.blank?}
  validate :update_event_listing_updated_at, :if => Proc.new{|p| p.all_events_listing_changed?}
  validates_length_of :user_agreement_text, :maximum => 100, :message => "Text must be less than 100 characters"

  after_save :update_last_updated_model
  before_save :rename_image_file_name
  
  default_scope { order('created_at desc') }

  aasm :column => :status do  # defaults to aasm_state
    state :draft, :initial => true
    state :submitted

    event :submit_to_store do
      transitions :from => [:draft], :to => [:submitted]
    end 
    event :remove_from_store do
      transitions :from => [:submitted], :to => [:draft]
    end 
  end

  def new_mobileapp_set_push_fcm
    self.update_column('android_push_service','fcm')
  end 
   
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_social_media_status
    if self.social_media_status.blank?
      self.update_column(:social_media_status, 'deactive')
    end
  end

  def listing_screen_text_color_presentce
    if self.application_type != "single event" 
      errors.add(:listing_screen_text_color , "This field is required.") if self.listing_screen_text_color.blank?
    else
      self.errors.delete(:listing_screen_text_color)
    end
  end
  def mobile_app_status(status)
    if status== "submit_to_store"
      self.submit_to_store!
    end
  end

  def splash_screen_url(style=:large)
    if self.parent_id.present? and not self.splash_screen.exists?
      parent = MobileApplication.find(self.parent_id)
      style.present? ? parent.splash_screen.url(style) : parent.splash_screen.url
    else
      style.present? ? self.splash_screen.url(style) : self.splash_screen.url
    end
  end

  def login_background_url(style=:large)
    if self.parent_id.present? and not self.login_background.exists?
      parent = MobileApplication.find(self.parent_id)
      style.present? ? parent.login_background.url(style) : parent.login_background.url
    else
      style.present? ? self.login_background.url(style) : self.login_background.url
    end
  end

  def listing_screen_background_url(style=:large)
    if self.parent_id.present? and not self.listing_screen_background.exists?
      parent = MobileApplication.find(self.parent_id)
      style.present? ? parent.listing_screen_background.url(style) : parent.listing_screen_background.url
    else
      style.present? ? self.listing_screen_background.url(style) : self.listing_screen_background.url
    end
  end

  def visitor_registration_background_image_url(style=:large)
    if self.parent_id.present? and not self.visitor_registration_background_image.exists?
      parent = MobileApplication.find(self.parent_id)
      style.present? ? parent.visitor_registration_background_image.url(style) : parent.visitor_registration_background_image.url
    else
      style.present? ? self.visitor_registration_background_image.url(style) : self.visitor_registration_background_image.url
    end
  end

  def visitor_registration_back_color
    self.visitor_registration_background_color.present? ? self.visitor_registration_background_color : " "
  end

  def data_visible
    arr = ["Agenda","EventFeature","Poll","EKit","Speaker","Quiz","FeedbackForm"]
    flag = []
    arr.each do |a|
      info = a.constantize.where(:event_id => self.events.pluck(:id)) rescue []
      flag << info.pluck("#{get_visiblity_column_name(a)}")
    end
    return flag.flatten.include? "group"
  end


  def app_icon_url(style=:large)
    if self.parent_id.present? and not self.app_icon.exists?
      parent = MobileApplication.find(self.parent_id)
      style.present? ? parent.app_icon.url(style) : parent.app_icon.url
    
    else
      style.present? ? self.app_icon.url(style) : self.app_icon.url
    end
  end

  def update_client_id
    if self.events.present?
      self.update_column(:client_id, self.events.first.client_id)
    end
  end

  def self.search(params, mobileapplications)
    keyword = params[:search][:keyword]
    mobileapplications = mobileapplications.where("name like (?)", "%#{keyword}%")if keyword.present?
    mobileapplications 
  end

  def set_preview_submitted_code
    new_preview_code = ""
    loop do
      new_preview_code = (0...5).map { ('A'..'M').to_a[rand(13)] }.join
      new_preview_code = "P" + new_preview_code
      break new_preview_code unless MobileApplication.pluck(:preview_code).include?(new_preview_code)
    end
    self.update_column(:preview_code, new_preview_code)

    new_submitted_code = ""
    loop do
      new_submitted_code = (0...5).map { ('N'..'Z').to_a[rand(13)] }.join
      new_submitted_code = "S" + new_submitted_code
      break new_submitted_code unless MobileApplication.pluck(:submitted_code).include?(new_submitted_code)
    end
    self.update_column(:submitted_code, new_submitted_code)
  end

  def review_status
    features_arr = ['name', 'application_type', 'template_id', 'app_icon_file_name', 'splash_screen_file_name']
    extra_count = 0
    if self.login_at == 'Yes'
      features_arr += ['login_background_file_name']
    else
      extra_count += 1 if self.login_at.present?
    end
    features_arr += ['listing_screen_background_file_name', 'listing_screen_text_color'] if (self.application_type == 'multi event' and self.marketing_app_event_id.blank?)
    ReviewStatus.review(self, features_arr, extra_count, (features_arr.length + extra_count))
  end

  def old_review_status
    features_arr = {'name' => '', 'application_type' => '', 'template_id' => '', 'app_icon_file_name' => '', 'login_at' => ''}
    features_arr.merge!('listing_screen_background_file_name' => '') if self.application_type == 'multi event'
    features_arr.merge!('login_background_file_name' => '') if self.login_at == 'Yes'
    ReviewStatus.review(self, features_arr)
  end

  # def new_review_status(objekt, features_arr)
  #   #features_arr = {'name' => '', 'application_type@@multi event' => ['listing_screen_background'], 'template_id' => '', 'app_icon' => '', 'login_at@@yes' => ['login_background']}
  #   count, total = 0, features_arr.length
  #   features_arr.keys.each do |feature|
  #     field_name, value = feature.split('@@')
  #     if objekt.attribute_present? (field_name) and (value.blank? or (value.present? and objekt.attributes[field_name] == value))
  #       count, total = count+1, (total+features_arr[feature].length)
  #       if features_arr[feature].present?
  #         features_arr[feature].each do |sub_feature|
  #           sub_field_name, sub_value = sub_feature.split('@@')  
  #           count += 1 if objekt.attribute_present? (sub_field_name) and (sub_value.blank? or (sub_value.present? and objekt.attributes[sub_field_name] == sub_value))
  #         end
  #       end
  #     end
  #   end
  #   ((count/total.to_f) * 100).to_i
  # end

  def image_dimensions_for_app_icon
    mobile_dimension_height_app_icon, mobile_dimension_width_app_icon  = 180.0, 180.0
    dimensions_app_icon = Paperclip::Geometry.from_file(app_icon.queued_for_write[:original].path)
    errors.add(:app_icon, "Image size should be 180x180px only") if (dimensions_app_icon.width != mobile_dimension_width_app_icon or dimensions_app_icon.height != mobile_dimension_height_app_icon)
  end
  
  def image_dimensions_for_splash_screen
    mobile_dimension_height_splash_screen, mobile_dimension_width_splash_screen  = 1600.0, 960.0
    dimensions_splash_screen = Paperclip::Geometry.from_file(splash_screen.queued_for_write[:original].path)
    errors.add(:splash_screen, "Image size should be 960x1600px only") if (dimensions_splash_screen.width != mobile_dimension_width_splash_screen or dimensions_splash_screen.height != mobile_dimension_height_splash_screen)
  end
  
  def image_dimensions_for_login_background
    mobile_dimension_height_login_background,mobile_dimension_width_login_background  = 1600.0, 960.0
    dimensions_login_background = Paperclip::Geometry.from_file(login_background.queued_for_write[:original].path)
    errors.add(:login_background, "Image size should be 960x1600px only") if (dimensions_login_background.width != mobile_dimension_width_login_background or dimensions_login_background.height != mobile_dimension_height_login_background)
  end
  
  def image_dimensions_for_screen_background
    mobile_dimension_height_listing_screen_background, mobile_dimension_width_listing_screen_background  = 1600.0, 960.0
    dimensions_listing_screen_background = Paperclip::Geometry.from_file(listing_screen_background.queued_for_write[:original].path)
    errors.add(:listing_screen_background, "Image size should be 960x1600px only")  if (dimensions_listing_screen_background.width != mobile_dimension_width_listing_screen_background or dimensions_listing_screen_background.height != mobile_dimension_height_listing_screen_background)
  end

  def registration_background_image_or_color_present
    errors.add(:visitor_registration_background_image, "This field is required.") if (visitor_registration_background_image_file_name.blank?)
    errors.add(:visitor_registration_background_color, "This field is required.") if (visitor_registration_background_color.blank?)
  end

  def change_status(mobile_app)
    if mobile_app == "submit_to_store"
      self.submit_to_store!
    elsif mobile_app == "remove_from_store"
      self.remove_from_store!
    end
  end

  def get_events(user,events)
    if user.has_role? :moderator or user.has_role? :event_admin or user.has_role? :db_manager
      apps = self.events.where(:id => events.pluck(:id)).order(start_event_date: :desc) rescue []
    else
      apps = self.events.where(:marketing_app => nil).order(start_event_date: :desc) rescue []
    end  
    apps
  end

  def get_events_for_marketing_app(user,events)
    if user.has_role? :moderator or user.has_role? :event_admin or user.has_role? :db_manager
      apps = self.events.where(:id => events.pluck(:id)).order(start_event_date: :desc) rescue []
    else
      apps = self.events.where(:marketing_app => nil).order(start_event_date: :desc) rescue []
    end  
    apps
  end

  def self.get_mobile_application_name(id)
    MobileApplication.find_by_id(id)
  end

  def rename_image_file_name
    if (self.app_icon_updated_at_changed? and self.app_icon_file_name.present?)
      extension = File.extname(app_icon_file_name).downcase
      self.app_icon_file_name = "#{Time.now.to_i.to_s}_1#{extension}"
    end
    if (self.splash_screen_updated_at_changed? and self.splash_screen_file_name.present?)
      extension = File.extname(splash_screen_file_name).downcase
      self.splash_screen_file_name = "#{Time.now.to_i.to_s}_2#{extension}"
    end
    if (self.login_background_updated_at_changed? and self.login_background_file_name.present?)
      extension = File.extname(login_background_file_name).downcase
      self.login_background_file_name = "#{Time.now.to_i.to_s}_3#{extension}"
    end
    if (self.listing_screen_background_updated_at_changed? and self.listing_screen_background_file_name.present?)
      extension = File.extname(listing_screen_background_file_name).downcase
      self.listing_screen_background_file_name = "#{Time.now.to_i.to_s}_4#{extension}"
    end
    if (self.visitor_registration_background_image_updated_at_changed? and self.visitor_registration_background_image_file_name.present?)
      extension = File.extname(visitor_registration_background_image_file_name).downcase
      self.visitor_registration_background_image_file_name = "#{Time.now.to_i.to_s}_5#{extension}"
    end
  end

  def update_event_listing_updated_at
    self.update_column("event_listing_display_updated_at",Time.now)
  end

  def self.get_content_data(event)
    content_Arry = ["abouts","speakers","agendas","invitees","sponsors","exhibitors","my_travels","faqs", "awards", "images","contacts","custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"]
    features = []
    content_Arry.each do |feature|
      if feature == "abouts"
        features << feature if event.about_language_updated == false  
      elsif feature == "event_highlights"
        features << feature if event.highlight_language_updated == false  
      else
        features << feature if event.send(feature).present? and event.send(feature).pluck(:language_updated).include? false
      end
    end
    features 
  end  

  def check_privacy_policy_value_present
    if self.agreeing_terms_and_conditions.present? and self.agreeing_terms_and_conditions == "yes"
      errors.add(:user_agreement_text, "This field is required.") if (self.user_agreement_text.blank?)
      errors.add(:url_1_link, "This field is required.") if (self.url_1_text.present? and self.url_1_link.blank?)
      errors.add(:url_2_link, "This field is required.") if (self.url_2_text.present? and self.url_2_link.blank?)
      if (self.url_1_text.present? and self.url_1_link.present?)
        uri = URI.parse(self.url_1_link)
        link_1_valid = (uri.is_a?(URI::HTTP) && !uri.host.nil?) ? "valid" : "invalid"
        errors.add(:url_1_link, "This is not a valid URL") if (link_1_valid.present? and link_1_valid == "invalid")
      end
      if (self.url_2_text.present? and self.url_2_link.present?)
        uri = URI.parse(self.url_2_link)
        link_2_valid = (uri.is_a?(URI::HTTP) && !uri.host.nil?) ? "valid" : "invalid"
        errors.add(:url_2_link, "This is not a valid URL") if (link_2_valid.present? and link_2_valid == "invalid")
      end
    end
  end

  def get_events_data(event_id = nil)
    if self.application_type == 'multi event'
      if event_id.present?
        self.events.where(:id => event_id).as_json(:methods => [:logo_url,:inside_logo_url, :about_date, :event_start_time_in_utc, :display_time_zone,:footer_image_url])
      else
        []
      end
    else
      self.events.as_json(:methods => [:logo_url,:inside_logo_url, :about_date, :event_start_time_in_utc, :display_time_zone,:footer_image_url])
    end
  end
  
  def fetch_events(invitee)
    events = []
    if self.all_events_listing == "yes" 
      event_approved = self.events.where("status =? or  status =? ", "approved", "published")
      events = event_approved
    elsif self.all_events_listing == "no" and invitee.present? 
      event_ids = Invitee.where(event_id: self.events.pluck(:id), email: invitee.email).pluck(:event_id)
      total_events = Event.where(:id => event_ids)
      events = total_events.where("status =? or  status =? ", "approved", "published")
    end
    events
  end

  def self.get_mobile_application(mobile_application_code)
    MobileApplication.find_by_submitted_code(mobile_application_code) || MobileApplication.find_by_preview_code(mobile_application_code)
  end

  def self.get_records(params)
    data = {}
    if params[:mobile_application_preview_code].present? 
      mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    elsif params[:mobile_application_code].present? or params["mobile_application_id"].present?
      mobile_application = MobileApplication.where('submitted_code =? or preview_code =? or id =?', params[:mobile_application_code], params[:mobile_application_code], params["mobile_application_id"]).first
    elsif params["id"].present?
      mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params[:id], params[:id]).first
    end
    data[:mobile_applications] = mobile_application.as_json(:only => [:id,
                                           :login_background_color,
                                           :message_above_login_page,
                                           :registration_message,
                                           :registration_link,
                                           :login_button_color,
                                           :login_button_text_color,
                                           :listing_screen_text_color,
                                           :social_media_status,
                                           :visitor_registration,
                                           :social_media_logins,
                                           :choose_home_page,
                                           :home_page_event_id,
                                           :app_icon_updated_at,
                                           :splash_screen_updated_at,
                                           :login_background_updated_at,
                                           :listing_screen_background_updated_at,
                                           :all_events_listing],
                                     :methods => [:app_icon_url,
                                                 :splash_screen_url,
                                                 :login_background_url,
                                                 :listing_screen_background_url,
                                                 :visitor_registration_background_image_url,
                                                 :visitor_registration_back_color,
                                                 :marketing_app_event_id,
                                                 :data_visible ])   
  end

  def multilingual_app
    self.events.pluck(:parent_id).compact.present?
  end
end
