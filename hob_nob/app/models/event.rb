class Event < ActiveRecord::Base
  require 'review_status'
  require "copy_event"

  resourcify
  serialize :preferences
  
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :event_theme, :event_limit, :parent_event_id, :event_date_limit,:timezone_landing_app,:copy_modules,:copy_mobile_application_module, :skip_validation

  EVENT_FEATURE_ARR = ['speakers', 'invitees', 'agendas', 'polls', 'conversations', 'faqs', 'awards', 'qnas','feedbacks', 'e_kits', 'abouts', 'galleries', 'notes', 'contacts', 'event_highlights', 'highlight_images', 'emergency_exits','venue','maps']
  REVIEW_ATTRIBUTES = {'template_id' => 'Template', 'app_icon_file_name' => 'App Icon', 'app_icon' => 'App Icon', 'name' => 'Name', 'application_type' => 'Application Type', 'listing_screen_background_file_name' => 'Listing Screen Background', 'listing_screen_background' => 'Listing Screen Background', 'login_background' => 'Login Background', 'login_background_file_name' => 'Login Background', 'login_at' => 'Login At', 'logo' => 'Event Listing Logo', 'inside_logo' => 'Inside Logo', 'logo_file_name' => 'Event Listing Logo', 'inside_logo_file_name' => 'Inside Logo', 'theme_id' => 'Preview Theme', "splash_screen_file_name" => "Splash Screen","visitor_registration" => "Visitor Registration"}

  FEATURE_TO_MODEL = {"contacts" => 'Contact',"speakers" => 'Speaker',"invitees" => 'Invitee',"agendas" => 'Agenda',"faqs" => 'Faq',"qnas" => 'Qna',"conversations" => 'Conversation',"polls" => 'Poll',"awards" => 'Award',"sponsors" => 'Sponsor',"feedbacks" => 'Feedback',"panels" => 'Panel',"event_features" => 'EventFeature',"e_kits" => 'EKit',"quizzes" => 'Quiz',"favorites" => 'Favorite',"exhibitors" => 'Exhibitor', 'galleries' => 'Image', 'emergency_exits' => 'EmergencyExit', 'attendees' => 'Attendee', 'my_travels' => 'MyTravel', 'custom_page1s' => 'CustomPage1', 'custom_page2s' => 'CustomPage2', 'custom_page3s' => 'CustomPage3', 'custom_page4s' => 'CustomPage4', 'custom_page5s' => 'CustomPage5', 'custom_page6s' => 'CustomPage6', 'custom_page7s' => 'CustomPage7', 'custom_page8s' => 'CustomPage8', 'custom_page9s' => 'CustomPage9', 'custom_page10s' => 'CustomPage10',"maps" => 'Map'}
  EVENT_ASSOCIATIONS = ['speakers', 'invitees', 'agendas', 'faqs', 'awards', 'contacts', 'highlight images', 'emergency exits', 'user registrations', 'sponsors', 'registrations', 'registration settings', 'my travels', 'invitee structures', 'invitee groups', 'images', 'groupings', 'exhibitors', 'features', 'custom page1s', 'custom page2s', 'custom page3s', 'custom page4s', 'custom page5s','custom page6s', 'custom page7s', 'custom page8s', 'custom page9s', 'custom page10s', 'campaigns', 'attendees', 'mobile application','maps', 'microsite_look_and_feels', 'microsites', 'microsite_features']

  COUNTRIES = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Congo", "Democratic Republic of the", "Congo", "Republic of the", "Costa Rica", "Cote dIvoire", "Croatia", "Cuba", "Curacao", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "East Timor", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea", "North", "Korea", "South", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Moldova", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territories", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Sint Maarten", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]

  MOBILE_APPLICATIONS = ['invitees', 'speakers', 'agendas', 'faqs', 'awards', 'contacts', 'event highlights', 'emergency exits', 'sponsors', 'my travels', 'gallery', 'exhibitors', 'custom page1', 'custom page2', 'custom page3', 'custom page4', 'custom page5']#, 'features']

  DATABASES = ['invitee structures', 'groupings']

  INVITEE_STRUCTURES=['registrations', 'registration settings']
  GROUPINGS = ['campaigns']

  belongs_to :client
  belongs_to :theme
  belongs_to :mobile_application
  has_one :contact
  has_one :emergency_exit
  has_one :qna_wall
  has_one :conversation_wall
  has_one :poll_wall
  has_one :quiz_wall
  has_many :my_profiles, :dependent => :destroy
  has_many :speakers, :dependent => :destroy
  has_many :event_venues#, :dependent => :destroy
  has_many :invitees, :dependent => :destroy
  has_many :attendees, :dependent => :destroy
  has_many :agendas, :dependent => :destroy
  has_many :faqs, :dependent => :destroy
  has_many :qnas, :dependent => :destroy
  has_many :conversations, :dependent => :destroy
  has_many :polls, :dependent => :destroy
  has_many :awards, :dependent => :destroy
  has_many :sponsors, :dependent => :destroy
  has_and_belongs_to_many :users
  has_many :feedbacks, :dependent => :destroy
  has_many :feedback_forms, :dependent => :destroy
  has_many :images, as: :imageable, :dependent => :destroy
  has_many :panels, :dependent => :destroy
  has_many :event_features, :dependent => :destroy
  has_many :feedbacks, :dependent => :destroy
  has_many :e_kits, :dependent => :destroy
  has_many :contacts, :dependent => :destroy 
  has_many :notifications, :dependent => :destroy
  has_many :highlight_images, :dependent => :destroy
  has_many :groupings, :dependent => :destroy
  has_many :quizzes, :dependent => :destroy
  has_many :invitee_structures, :dependent => :destroy
  has_many :favorites, :dependent => :destroy
  has_many :groupings, :dependent => :destroy
  has_many :exhibitors, :dependent => :destroy
  has_many :registration_settings, :dependent => :destroy
  has_many :registrations, :dependent => :destroy
  has_many :user_registrations, :dependent => :destroy
  has_many :analytics, :dependent => :destroy
  has_many :custom_page1s, :dependent => :destroy
  has_many :custom_page2s, :dependent => :destroy
  has_many :custom_page3s, :dependent => :destroy
  has_many :custom_page4s, :dependent => :destroy
  has_many :custom_page5s, :dependent => :destroy
  has_many :custom_page6s, :dependent => :destroy
  has_many :custom_page7s, :dependent => :destroy
  has_many :custom_page8s, :dependent => :destroy
  has_many :custom_page9s, :dependent => :destroy
  has_many :custom_page10s, :dependent => :destroy
  has_many :chats, :dependent => :destroy
  has_many :invitee_groups, :dependent => :destroy
  has_many :my_travels, :dependent => :destroy
  has_many :telecaller_accessible_columns, :dependent => :destroy
  has_many :consent_questions, :dependent => :destroy
  has_many :onsite_accessible_columns, dependent: :destroy
  has_one :map, :dependent => :destroy
  has_and_belongs_to_many :campaigns
  #has_many :venue_sections, :dependent => :destroy
  has_many :agenda_tracks, :dependent => :destroy
  has_one :badge_pdf, :dependent => :destroy
  has_many :manage_invitee_fields, :dependent => :destroy
  #has_many :my_travel_docs, :dependent => :destroy
  #has_many :courses, :dependent => :destroy
  #has_many :course_providers, :dependent => :destroy
  has_many :qna_settings, :dependent => :destroy
  has_many :registration_look_and_feels, :dependent => :destroy
  has_many :track_links, :dependent => :destroy
  has_many :telecaller_groups
  has_one :microsite, :dependent => :destroy
  has_one :smtp_setting
  has_many :folders

  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :event_features
  accepts_nested_attributes_for :event_venues
  
  validates :primary_language, presence:{ :message => "This field is required." }, on: :update
  validates :event_name, :client_id, :cities,:event_type_for_registration, presence:{ :message => "This field is required." }
  validates :start_event_date,:end_event_date, presence:{ :message => "This field is required." }, :if => Proc.new{|p|p.marketing_app.blank?}
  #validates :primary_language, presence:{ :message => "This field is required." }, :if => Proc.new{|p|p.copy_multi_lng_event.blank?}
  validates :country_name,:timezone, presence:{ :message => "This field is required." }
  validates :pax, :numericality => { :greater_than_or_equal_to => 0}, :allow_blank => true
  validate :end_event_time_is_after_start_event_time 
  validate :image_dimensions, :footer_image_dimensions, :unless => Proc.new{|p| p.skip_validation.present?}
 
  has_attached_file :logo, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(EVENT_LOGO_PATH)
  has_attached_file :inside_logo, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(EVENT_INSIDE_LOGO_PATH)
  has_attached_file :footer_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(EVENT_FOOTER_IMAGE_PATH)                                       
  validates_attachment_content_type :logo, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :inside_logo, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :footer_image, :content_type => ["image/png"],:message => "please select valid format."
  validate :event_count_within_limit, :check_event_date, :on => :create
  before_create :set_preview_theme
  before_save :check_event_content_status#, :add_venues_from_event_venues 
  after_create :update_theme_updated_at, :set_uniq_token, :set_event_category,:assign_campaign_having_0_id_to_event
  after_save :update_login_at_for_app_level, :set_date, :set_timezone_on_associated_tables, :update_last_updated_model, :update_footer_updated_at
  validate :check_primary_language, :if => Proc.new{|p| p.parent_id.blank?}
  before_save :update_all_events_listing, :if => Proc.new{|p|p.login_at_changed?}
  after_create :set_event_has_multi_lng_event 
  after_save :set_seo_name
  scope :ordered, -> { order('start_event_time desc') }
  
  include AASM
  aasm :column => :status do
    state :pending, :initial => true
    state :approved
    state :rejected
    state :published
    
    event :approve do
      transitions :from => [:pending], :to => [:approved]
    end 
    event :reject do
      transitions :from => [:pending,:approved], :to => [:rejected]
    end
    event :publish, :after => [:chage_updated_at, :destroy_log_change_for_publish, :update_event_last_updated] do
      transitions :from => [:approved], :to => [:published]
    end
    event :unpublish, :after => :create_log_change do
      transitions :from => [:published], :to => [:approved]
    end
  end 
  def check_primary_language
    if self.primary_language.blank? 
      errors.add(:primary_language, "This field is required.")
    end
  end
  def set_seo_name
    another_seo_name = Event.where("seo_name = ? and id != ?",self.event_name.parameterize,self.id)
    if another_seo_name.present?
     self.update_column(:seo_name,self.event_name.parameterize + '-' + self.id.to_s)
    else
     self.update_column(:seo_name,self.event_name.parameterize)
    end  
  end
  
  def set_event_has_multi_lng_event
    if self.parent_id.present?
      self.update_column('mult_lng_events',false)
    end  
  end    
 
  def content_is_present
    unless copy_content.blank? ^ custom_content.blank?
      errors.add(:copy_content, "This field is required.")
    end
  end
  
  def add_venues_from_event_venues
    if self.event_venues.present?
      self.venues = self.event_venues.first.venue
      # self.venues = event_venue
    end
  end

  def event_venue_name
    self.event_venues.pluck(:venue).join('$$$$') if self.event_venues.present?
  end

  def init
    self.status = "pending"
    self.event_theme = "create your own theme"
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_footer_updated_at
    if self.footer_image_file_name_changed? and self.footer_image_file_name.to_s == ""
      self.update_column("footer_image_updated_at", Time.now)
    end
  end

  def update_theme_updated_at
    self.theme.update_column(:updated_at, Time.now) rescue nil
  end

  def update_login_at_for_app_level
    if self.login_at == "Before Interaction" or self.login_at == "After Highlight"
      self.update_column(:rsvp, "No")
      self.update_column(:rsvp_message, nil)
      self.update_column(:updated_at, Time.now)
    end
    if self.mobile_application.present?
      app_login = self.login_at == 'After Splash' ? 'Yes' : 'No'
      self.mobile_application.update_column(:login_at, app_login)
      self.mobile_application.update_column(:updated_at, Time.now)
      self.mobile_application.events.each do |event|
        login_at = self.login_at || mobile_application.events.first.login_at rescue 'Before Interaction'
        event.update_column(:login_at, login_at)
        event.update_column(:updated_at, Time.now) rescue nil
      end
    end
  end

  def set_preview_theme
    self.theme_id = Theme.where(:admin_theme => true, :preview_theme => "yes").first.id rescue nil
  end

  def self.search(params, events)
    event_name, end_date, start_date, order_by, order_by_status = params[:search][:name], params[:search][:end_date], params[:search][:start_date], params[:search][:order_by], params[:search][:order_by_status] if params[:adv_search].present?
    basic = params[:search][:keyword]
    if event_name.present?
      events = events.where("event_name like (?)","%#{event_name}%")
    end
    if end_date.present?
      events = events.where("end_event_date >=? and end_event_date <= ? ", end_date.to_datetime, (end_date.to_datetime.next_day - 1.minutes))
    end
    if start_date.present?
      events = events.where("start_event_date >=? and start_event_date <= ? ", start_date.to_datetime, (start_date.to_datetime.next_day - 1.minutes))
    end
    if order_by.present? and order_by == "upcoming"
      events = events.where('start_event_date > ? AND end_event_date > ?',Date.today,Date.today) 
    end
    if order_by.present? and order_by == "past"
      events = events.where('start_event_date < ? AND end_event_date < ?',Date.today, Date.today) 
    end
    if order_by.present? and order_by == "ongoing"
      events = events.where('start_event_date <= ? AND end_event_date >= ?',Date.today,Date.today)
    end
    if order_by_status.present?
      events = events.where("status = ?", order_by_status) 
    end
    if basic.present?
      events = events.where("event_name like (?)", "%#{basic}%") 
    end
    events
  end 

  def logo_url(style=:small)
    style.present? ? self.logo.url(style) : self.logo.url
  end

  def inside_logo_url(style=:original)
    style.present? ? self.inside_logo.url(style) : self.inside_logo.url
  end

  def footer_image_url(style=:original)
    style.present? ? self.footer_image.url(style) : self.footer_image.url
  end

  def perform_event(event)
    self.approve! if event== "approve"
    self.reject! if event== "reject"
    self.publish! if event == "publish"
    self.unpublish! if event == "unpublish"
  end

  def add_features(params)
    if params[:event].present?
      params[:event][:features] = params[:event][:features].present? ? params[:event][:features] : []
      already_feature = self.event_features.pluck(:name) 
      feature_delete = already_feature.select { |elem| (!params[:event][:features].include?(elem) and elem != "my_calendar")  }
      feature_delete.each {|f| self.event_features.where(:name => f).destroy_all}
      feature_to_add = params[:event][:features] - already_feature if params[:event][:features].present?
      feature_to_add.each_with_index do |f,i|
        seq = self.event_features.present? ? self.event_features.pluck(:sequence).compact.max.to_i + 1 : 1  
        f = "venue" if f == "emergency_exits"
        ef = self.event_features.new(name: f, page_title: Client::display_hsh1[f], sequence: seq, status: (f == "my_calendar" ? "deactive" : "active"))
        if self.save
          default_icon = (self.default_feature_icon == "custom" ? "new" : self.default_feature_icon )
          if self.default_feature_icon != "owns" and self.default_feature_icon != "new_menu" and !(/\A[-+]?\d+\z/ === default_icon)
            ef.update_attributes(:menu_icon => File.new("public/menu_icons/#{default_icon}_icons/#{Client::menu_icon[ef.name]}.png","rb"), :main_icon => File.new("public/main_icons/#{default_icon}_icons/#{Client::menu_icon[ef.name]}.png","rb")) rescue nil
          elsif self.default_feature_icon == "owns" or self.default_feature_icon == "new_menu"
            ef.menu_icon = nil
            ef.main_icon = nil
            ef.save
          elsif (/\A[-+]?\d+\z/ === default_icon)
            icons = IconLibrary.find(default_icon).icons
            if icons.present?
              ef.menu_icon = icons.where(:icon_name => ef.name).first.menu_icon if ["social_sharings","event_highlights","maps","my_calendar","custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].exclude?(ef.name)
              ef.main_icon = icons.where(:icon_name => ef.name).first.main_icon if ["contacts","venue","social_sharings","event_highlights","maps","my_calendar","custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].exclude?(ef.name)
              ef.save
            end
          end
        end if !(already_feature.include?(f)) 
      end
    else
      self.event_features.where("name != ?", "my_calendar").destroy_all
      self.update_column(:default_feature_icon, "new_menu")
    end
  end

  def add_single_features(params)
    unless self.event_features.pluck(:name).include?(params[:enable_event])
      seq = self.event_features.present? ? self.event_features.pluck(:sequence).compact.max.to_i + 1 : 1 rescue 1
      feature = params["enable_event"] == 'images' ? 'galleries' : params["enable_event"]
      default_status = (feature == "my_calendar" ? "deactive" : "active" )
      feature = self.event_features.new(name: feature, page_title: Client::display_hsh1[feature], sequence: seq, status: default_status)
      default_icon = (self.default_feature_icon == "custom" ? "new" : self.default_feature_icon )
      if feature.save
        if feature.name == "venue"
          if self.default_feature_icon != "owns" and self.default_feature_icon != "new_menu"
            feature.update_attributes(:menu_icon => File.new("public/menu_icons/#{default_icon}_icons/Venue.png","rb"), :main_icon => File.new("public/main_icons/#{default_icon}_icons/Venue.png","rb")) rescue nil
          elsif self.default_feature_icon == "owns" and self.default_feature_icon == "new_menu"
            feature.menu_icon = nil
            feature.main_icon = nil
            feature.save
          end
        else
          if self.default_feature_icon != "owns" and self.default_feature_icon != "new_menu"
            feature.update_attributes(:menu_icon => File.new("public/menu_icons/#{default_icon}_icons/#{Client::menu_icon[feature.name]}.png","rb"), :main_icon => File.new("public/main_icons/#{default_icon}_icons/#{Client::menu_icon[feature.name]}.png","rb")) rescue nil
          elsif self.default_feature_icon == "owns" and self.default_feature_icon == "new_menu"
            feature.menu_icon = nil
            feature.main_icon = nil
            feature.save
          end
        end
      end
    end
  end

  def remove_single_features(params)
    features = self.event_features
    feature_name = (params["disable_event"] == "images" ? "galleries" : params["disable_event"])    
    feature = features.find_by_name(feature_name)
    feature.destroy if feature.present?
    if self.event_features.blank?
      self.update_column(:default_feature_icon, "new_menu")
    end
  end

  def self.sort_by_type(type,events)
    if type == "upcoming_event"
      events = events.where(:event_category => "Upcoming")
    elsif type == "ongoing_event"
      events = events.where(:event_category => "Ongoing")
    else
      events = events.where(:event_category => "Past")
    end
    events
  end

  def set_status_for_licensee
    self.status = "approved"    
  end
  
  def set_features_default_list()
    default_features = ["abouts", "agendas", "speakers", "faqs", "galleries", "feedbacks", "e_kits","conversations","polls","awards","invitees","qnas", "notes", "contacts", "event_highlights","sponsors", "my_profile", "qr_code","quizzes","favourites","exhibitors",'venue', 'leaderboard', "custom_page1s", "custom_page2s", "custom_page3s","custom_page4s","custom_page5s","custom_page6s" ,"custom_page7s" ,"custom_page8s" ,"custom_page9s" ,"custom_page10s", "chats", "my_travels","social_sharings", "activity_feeds", "maps"]
    default_features = self.marketing_app == true ? default_features.push("all_events") : default_features
    default_features = self.marketing_app == true ? default_features - ["venue","exhibitors","my_travels"] : default_features
    default_features
  end

  def set_features_static_list()
    static_features = ["chat", "travel", "exhibitionguide"]
  end

  def set_features
    present_feature = self.event_features.pluck(:name) 
  end
  
  def set_time(start_event_date, start_time_hour, start_time_minute, start_time_am, end_event_date, end_time_hour, end_time_minute, end_time_am)
    start_event_time = "#{start_event_date} #{start_time_hour.gsub(':', "") rescue nil}:#{start_time_minute.gsub(':', "") rescue nil}:#{0} #{start_time_am}" if start_event_date.present?
    end_event_time = "#{end_event_date} #{end_time_hour.gsub(':', "") rescue nil}:#{end_time_minute.gsub(':', "") rescue nil}:#{0} #{end_time_am}" if end_event_date.present?
    if start_event_date.present? and [345, 360, 367, 173, 165, 168, 364, 365, 368, 333].include? self.id
      self.start_event_time = start_event_time
    elsif start_event_date.present?
      self.start_event_time = start_event_time.to_datetime
    end
    if end_event_date.present? and [345, 360, 367, 173, 165, 168, 364, 365, 368, 333].include? self.id
      self.end_event_time = end_event_time
    elsif end_event_date.present?
      self.end_event_time = end_event_time.to_datetime
    end
  end

  def end_event_time_is_after_start_event_time
    return if start_event_date.blank? || end_event_date.blank? #|| start_event_time.blank? || end_event_time.blank?
    if self.start_event_date.present? and self.end_event_date.present? and self.start_event_time.present? and self.end_event_time.present?
      if  self.start_event_time >= self.end_event_time
        errors.add(:end_event_date, "cannot be before the event start time")
      end
    end
  end

  def check_event_date
    if (User.current.has_role? "licensee_admin" and User.current.licensee_end_date.present? and self.marketing_app.blank?)
      if User.current.licensee_end_date.present? and self.end_event_date.present?
        if User.current.licensee_end_date < self.end_event_date
          errors.add(:event_date_limit, "Events end date needs to be between your licenseed end date.")
        else
          self.errors.delete(:event_date_limit)
        end
      end
    end
  end

  def check_event_content_status
    features = self.event_features.pluck(:name) - ['qnas', 'conversations', 'my_profile', 'qr_code','networks','favourites','my_calendar', 'leaderboard', 'custom_page1s', 'custom_page2s', 'custom_page3s', 'custom_page4s', 'custom_page5s', 'custom_page6s', 'custom_page7s', 'custom_page8s', 'custom_page9s', 'custom_page10s', 'social_sharings', 'notes', 'chats', 'activity_feeds','all_events','maps','courses']
    not_enabled_feature = Event::EVENT_FEATURE_ARR - features
    count = 0
    total_content_count = features.count
    content_missing_arr = []
    features.each do |feature|
      feature = 'images' if feature == 'galleries'
      if !(feature == 'abouts' or feature == 'qr_codes' or feature == 'notes' or feature == 'event_highlights' or feature == 'my_calendar' or feature == 'venue' or feature == 'social_sharings' or feature == 'all_events') and (feature != 'emergency_exits' and feature != 'emergency_exit') and (feature != 'maps' and feature != 'map')
        condition = (self.is_parent? ? self.association(feature).count : self.send(feature).where(:language_updated => true).count) <= 0 
      end
      condition, feature = EmergencyExit.where(:event_id => self.id).blank?, 'emergency_exits' if feature == 'emergency_exits' or feature == 'emergency_exit'
      if (condition or (feature == 'abouts' and self.about.blank? or feature == 'maps' and self.map.blank? or ((feature == 'event_highlights' and self.description.blank?) )))
        count += 1
        content_missing_arr << feature
      end
    end
    percent = (((count/total_content_count.to_f) * 100) == 0.0)? 100 : (100 - ((count/total_content_count.to_f) * 100)) if total_content_count != 0
    [content_missing_arr, not_enabled_feature, (percent.to_i/10) * 10]
  end

  def review_look_and_feel
    if self.mobile_application.present? and self.mobile_application.application_type == 'multi event' and self.mobile_application.marketing_app_event_id.blank?
      feature_arr = ['logo_file_name', 'inside_logo_file_name']
    else
      feature_arr = ['inside_logo_file_name']
    end
    review_arr = ReviewStatus.review(self, feature_arr)
    review_arr[0] = (review_arr[0]/2)
    review_arr[0] = review_arr[0].to_i + 50 if !self.theme.is_preview? rescue nil
    review_arr[1] << 'theme_id' if self.theme.is_preview? rescue nil
    review_arr
  end

  def review_features
    self.event_features.where("name != ?", "my_calendar").present? ? 100 : 0
  end

  def review_menus
    percentage = 0
    total = 0
    features = self.event_features
    features = features.where("name NOT IN (?)", ["event_highlights","my_calendar","chats","social_sharings"])
    feature_length = features.length
    total = feature_length * 2 if feature_length.present?
    count = 0
    missing_data = []
    features.each do |feature|
      feature.menu_icon.present? ? count = count + 1 : (missing_data << {:feature => feature.name, :icon => "Drawer Icon"})
      if feature.menu_icon_visibility == "yes" 
        feature.main_icon.present? ? count = count + 1 : (missing_data << {:feature => feature.name, :icon => "Menu Icon"})
      end
      if ["contacts","venue"].include?(feature.name) and (total > 0)
        total = total - 1
      end
    end
    percentage = (count * 100)/(total)  if total != 0
    [percentage,missing_data]
  end

  def review_status(type)
    case type
      when 'app_info'
        per = self.mobile_application.review_status[0]
      when 'look_and_feel'
        per = self.review_look_and_feel[0]
      when 'features'
        per = self.review_features
      when 'menus'
        per = self.review_menus[0]
      when 'content'
        per = self.check_event_content_status[2]
      when 'store_info'
        per = 100
    end
    per
  end

  def avg_review
    if self.mobile_application.present?
      total = 5
      per = self.mobile_application.review_status[0] + self.review_look_and_feel[0] + self.review_features + self.review_menus[0] + self.check_event_content_status[2]
    (((per/total) / 10) * 10)
    end
  end

  def image_dimensions
    if self.inside_logo_file_name_changed?  
      inside_logo_dimension_height  = 300.0
      inside_logo_dimension_width = 1280.0
      dimensions = Paperclip::Geometry.from_file(inside_logo.queued_for_write[:original].path)
      if (dimensions.width != inside_logo_dimension_width or dimensions.height != inside_logo_dimension_height)
        errors.add(:inside_logo, "Image size should be 1280x300px only") if self.errors['inside_logo'].blank?
      else
        self.errors.delete(:inside_logo)
      end
    end
    if self.logo_file_name_changed?  
      logo_dimension_height  = 200.0
      logo_dimension_width = 200.0
      dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path)
      if (dimensions.width != logo_dimension_width or dimensions.height != logo_dimension_height)
        errors.add(:logo, "Image size should be 200x200px only") if self.errors['logo'].blank?
      else
        self.errors.delete(:logo)  
      end
    end
  end

  def footer_image_dimensions
    if self.footer_image_file_name_changed?
      theme_dimension_width = 500.0
      theme_dimension_height  = 180.0
      dimensions = Paperclip::Geometry.from_file(footer_image.queued_for_write[:original].path) rescue "Creating copy" 
      if (dimensions != "Creating copy" and (dimensions.width != theme_dimension_width or dimensions.height != theme_dimension_height))
        errors.add(:footer_image, "Image size should be 500x180 px only")
      end
    end
  end

  def decide_seq_no(seq_type,feature,featue_type)
    if featue_type == Winner
      award = feature.award
      objects = featue_type.where(:award_id => award.id)
    elsif featue_type == Image
      event = feature.imageable
      objects = featue_type.where(:imageable_id => event.id)
    elsif featue_type == AgendaTrack
      event = feature.event
       objects = featue_type.joins(:agendas).where(:event_id => event.id,:agenda_date =>feature.agenda_date.to_date).uniq.order(:sequence)
    else
      event = feature.event
      objects = featue_type.where(:event_id => event.id)
    end
    ids = objects.pluck(:id) 
    position = ids.index(feature.id)
    if featue_type == AgendaTrack
      if seq_type == "up"
        previous_sp = objects.find_by_id(ids[position.to_i - 1])
        old_seq = previous_sp.sequence
        previous_sp.update_column('sequence',feature.sequence)
        feature.update_column('sequence',old_seq)
        for agenda in feature.agendas
          agenda.update_attribute(:updated_at, Time.now.in_time_zone('UTC'))
        end
      else
        next_sp = objects.find_by_id(ids[position.to_i + 1])
        next_seq = next_sp.sequence
        next_sp.update_column('sequence',feature.sequence)
        feature.update_column('sequence',next_seq)
        for agenda in feature.agendas
          agenda.update_attribute(:updated_at, Time.new.in_time_zone('UTC'))
        end
      end if ids.length > 1
    elsif featue_type == Image
      if seq_type == "up"
        previous_sp = objects.find_by_id(ids[position.to_i - 1])
        old_seq = previous_sp.sequence
        previous_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => old_seq)
      else
        id = (position.to_i + 1 == ids.count) ? ids[0] : ids[position.to_i + 1]
        next_sp = objects.find_by_id(id)
        next_seq = next_sp.sequence
        next_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => next_seq)
      end if ids.length > 1 
    else
      if seq_type == "up"
        previous_sp = objects.find_by_id(ids[position.to_i - 1])
        old_seq = previous_sp.sequence
        previous_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => old_seq)
      else
        next_sp = objects.find_by_id(ids[position.to_i + 1])
        next_seq = next_sp.sequence
        next_sp.update(:sequence => feature.sequence)
        feature.update(:sequence => next_seq)
      end if ids.length > 1
    end
  end

  def chage_updated_at
    self.theme.update_column(:updated_at, Time.now)
    ["contacts","speakers","invitees","agendas","faqs","qnas","conversations","polls","awards","sponsors","feedbacks","panels","event_features","e_kits","quizzes","favorites","exhibitors",'galleries', 'emergency_exits', 'attendees', 'my_travels', 'custom_page1s', 'custom_page2s', 'custom_page3s', 'custom_page4s', 'custom_page5s',"custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].each do |t|
      FEATURE_TO_MODEL[t].constantize.where(:event_id => self.id).update_all(:updated_at => Time.now) if t != 'galleries'
      FEATURE_TO_MODEL[t].constantize.where(:imageable_id => self.id, :imageable_type => 'Event').update_all(:updated_at => Time.now) if t == 'galleries'
    end
  end

  def create_log_change
    LogChange.create(:changed_data => nil, :resourse_type => "Event", :resourse_id => self.id, :user_id => nil, :action => "destroy") rescue nil
  end

  def destroy_log_change_for_publish
    log_changes = LogChange.where(:resourse_type => "Event", :resourse_id => self.id, :action => "destroy")
    log_changes.each{|l| l.update_column("action", "unpublished")}
  end

  def update_event_last_updated
    self.update_column("published_at", Time.now)
  end

  def add_default_invitee
    invitee = self.invitees.new(name_of_the_invitee: "Preview", email: "preview@previewapp.com", password: "preview", invitee_password: "preview", :first_name => 'Preview', :last_name => 'Invitee', :copy_event => true)
    invitee.save rescue ""
  end

  def get_agenda
    Agenda.where(:event_id => self.id).pluck(:agenda_type).uniq.compact rescue []
  end

  def get_event_agenda_tracks
    AgendaTrack.joins(:agendas).where(:event_id => self.id)
  end
  
  def event_count_within_limit
    if (User.current.has_role? "licensee_admin" and User.current.no_of_event.present?) or (self.client.licensee.present? and self.client.licensee.no_of_event.present?)
      clients = Client.with_roles(User.current.roles.pluck(:name), User.current).uniq
      event_count = clients.map{|c| c.events.count}.sum
      if (User.current.no_of_event.present? and User.current.no_of_event <= event_count) or (self.client.licensee.present? and self.client.licensee.no_of_event <= event_count)
        errors.add(:event_limit, "You have crossed your events limit kindly contact.")
        # errors.add(:event_limit, "Exceeded the event limit: #{User.current.no_of_event} ")
      else
        self.errors.delete(:event_limit)
      end 
    end
  end

  def get_event_feature_status
    calendar = self.event_features.where(:name => "my_calendar")
    if calendar.present?
      calendar.first.menu_icon_visibility.downcase rescue ""
    else
      ""
    end
  end

  def get_event_session_to_my_agenda_status
    calendar = self.event_features.where(:name => "my_calendar")
    if calendar.present?
      calendar.first.session_to_agenda.downcase rescue ""
    else
      ""
    end
  end
  def get_category_faq_setting_status
    faq = self.event_features.where(:name => "faqs")
    if faq.present?
      faq.first.faq_setting.downcase rescue ""
    else
      ""
    end
  end

  def get_gallery_folder_setting_status
    gallery = self.event_features.where(:name => "galleries")
    if gallery.present?
      gallery.first.image_setting.downcase rescue ""
    else
      ""
    end
  end

  def validate_rsvp_text(params)
    if params[:event].present? and params[:event][:rsvp_message].blank?
      errors.add(:rsvp_message, "This field is required.")
      return false
    else
      errors.delete(:rsvp_message)
      return true
    end 
  end

  def self.get_event_by_id(id)
    self.find_by_id(id)
  end

  def self.get_associated_module_data(feature,id)
    feature.find_by_id(id)
  end

  def set_uniq_token
    loop do
      uniq_token = Devise.friendly_token
      break uniq_token if Event.pluck(:token).exclude?(uniq_token)
    end
    self.update_column(:token, uniq_token) rescue nil
  end

  def get_licensee_admin
    self.client.licensee rescue nil
  end

  def name_with_email
    users = []
    self.invitees.each do |user|
      if user.last_name.present?
        users << "#{user.first_name.to_s + " " + user.last_name.to_s}(#{user.email})"
      else
        users << "#{user.first_name}(#{user.email})"
      end
    end
    users
  end

  def set_timezone_on_associated_tables
    if self.timezone_changed?
      self.update_column("timezone", self.timezone.titleize) if !self.timezone.include? "US"
      self.update_column("timezone_offset", ActiveSupport::TimeZone[self.timezone].at(self.start_event_time).utc_offset)
      display_time_zone = self.display_time_zone
      for table_name in ["agendas", "chats", "conversations", "notifications","qnas"]
        table_name.classify.constantize.where(:event_id => self.id).each do |obj|
          obj.update_column("event_timezone", self.timezone)
          obj.update_column("event_timezone_offset", self.timezone_offset)
          obj.update_column("event_display_time_zone", display_time_zone)
          obj.update_column("updated_at", Time.now)
          obj.update_last_updated_model
          for c in obj.comments
            c.update_column("updated_at", Time.now)
            Rails.cache.delete("formatted_created_at_with_event_timezone_#{c.id}")
            Rails.cache.delete("formatted_updated_at_with_event_timezone_#{c.id}")
          end if table_name == "conversations"
        end
      end
    end
  end

  def set_date
    self.update_column(:start_event_date, self.start_event_time)
    self.update_column(:end_event_date, self.end_event_time)
  end

  def about_date
    if self.start_event_date.present? and self.end_event_date.present?
      if self.start_event_date.to_date != self.end_event_date.to_date
        "#{self.start_event_date.strftime('%d %b')} - #{self.end_event_date.strftime('%d %b %Y')}"
      else
        self.start_event_date.strftime('%A, %d %b %Y')
      end
    end
  end

  def self.set_event_category
    Event.find_each do |event|
      event.set_event_category rescue nil
    end
  end

  def set_event_category
    time_now = Time.now.in_time_zone(self.timezone).strftime("%d-%m-%Y %H:%M").to_datetime
      if self.start_event_time.present? and self.end_event_time.present?
        prev_event_category  = self.event_category
        if self.start_event_time <= time_now and self.end_event_time >= time_now
          self.update_column("event_category","Ongoing")
        elsif self.start_event_time > time_now
          self.update_column("event_category","Upcoming")
        elsif self.end_event_time < time_now
          self.update_column("event_category","Past")
        end
      self.update_column("updated_at",Time.now) if (prev_event_category != self.event_category)
    end
  end

  def event_start_time_in_utc
    event_time_in_timezone = self.start_event_time
    difference_in_seconds = Time.now.utc.utc_offset - Time.now.in_time_zone(self.timezone).utc_offset
    if difference_in_seconds < 0
      difference_in_hours = (difference_in_seconds.to_f/60/60).abs
      self.start_event_date - difference_in_hours.hours
    else
      difference_in_hours = (difference_in_seconds.to_f/60/60)
      self.start_event_date + difference_in_hours.hours
    end
  end

  def display_time_zone
    event_tz = "GMT +00:00"
    for tz in ActiveSupport::TimeZone.all.uniq{|e| ["GMT#{e.at(self.start_event_time).formatted_offset}"]}
      event_tz = "GMT#{tz.at(self.start_event_time).formatted_offset}".gsub("GMT", "GMT ") if tz.name == self.timezone
    end
    return event_tz
  end

  def extra_invitee_attributes
    h = {}
    my_profile = self.my_profiles.last
    ['attr1', 'attr2', 'attr3', 'attr4', 'attr5'].each do |t|
      h[t] = my_profile.attributes[t] if my_profile.attributes[t].present? and my_profile.attributes['enabled_attr'][t] == 'yes'
    end if my_profile.present?
    h
  end

  def get_invitee_my_profile_attributes
    h = {}
    my_profile = self.my_profiles.last
    h = my_profile.attributes['enabled_attr'] rescue {}
    h
  end
  
  def create_marketing_app_event
    self.marketing_app = true
    self.event_name = "Landing App"
    self.cities = "Mumbai"
    self.start_event_date = Time.now + 5.5.hours
    self.start_event_time = Time.now + 5.5.hours
    self.end_event_date = "31/12/2050".to_datetime
    self.end_event_time = "31/12/2050".to_datetime
    self.country_name = "India"
    self.timezone = "Chennai"
    self.event_type_for_registration = "open"
    self.status = "approved" 
    self.primary_language = "English"
    if self.save
      result = "true"
    else
      result = "false"
    end
    result
  end

  def update_all_events_listing
    self.mobile_application.update_column('all_events_listing','yes')
  end

  def assign_campaign_having_0_id_to_event
    if self.present? 
      campaign = Campaign.where(:id => 0).first
      if (campaign.present? and self.campaigns.pluck(:id).exclude?(0))
        self.campaigns << campaign
        event_campaign = self.campaigns.where(:id => 0).first
      end
    end
    if (self.inside_logo_updated_at_changed? and self.inside_logo_file_name.present?)
      extension = File.extname(inside_logo_file_name).downcase
      self.inside_logo_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end 
    if (self.footer_image_updated_at_changed? and self.footer_image_file_name.present?)
      extension = File.extname(footer_image_file_name).downcase
      self.footer_image_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end   
  end 

  def copy(features, is_multilingual = false)
    CopyEvent.copy(self, features, is_multilingual)
  end

  def is_parent?
    self.parent_id.blank?
  end
  
  def visibility_status
    status = []
    ["agendas", "event_features", "e_kits", "feedback_forms", "polls","quizzes","speakers"].each do |table|
      if self.send(table).pluck(:"#{get_visiblity_column_name(table.classify)}").include? "group"
        status << true
      end
    end  
    return status.include? true
  end

  def visibility_tables
    table_array = []
    ["agendas", "event_features", "e_kits", "feedback_forms", "polls","quizzes","speakers"].each do |table|
      if self.send(table).pluck(:"#{get_visiblity_column_name(table.classify)}").include? "group"
        table_array << table 
      end
    end  
    table_array
  end

  def onsite_registration_fields
    Hash[onsite_selected_columns.zip(onsite_selected_values)]
  end

  def onsite_selected_columns
    registrations.first.selected_columns
  end

  def onsite_selected_values
    registrations.first.selected_column_values
  end

  def invitee_datums
    invitee_structures.first.try(:invitee_datum)
  end
end
