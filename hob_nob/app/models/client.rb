class Client < ActiveRecord::Base

  include AASM  
  resourcify

  No_Data_Hash = {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client','events' => 'Event','speakers' => 'Speaker', 'invitees' => 'Invitee', 'agenda' => 'Session', 'polls' => 'Poll', 'conversations' => 'Conversation', 'faqs' => 'Faq', 'images' => 'Gallery', 'awards' => 'Award', 'qnas' => 'Q&A','feedbacks' => 'Feedback','feedback_forms' => 'FeedbackForm', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlight', 'abouts' => 'About', 'notifications' => 'Notification', 'emergency_exits' => 'Venue', 'event_features' => 'Event Feature', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Note', 'highlight_images' => 'Highlight Image', 'themes' => 'Theme', 'panels' => 'Panel','quizzes' => 'Quiz', "exhibitors" => "Exhibitor","registrations"=> "Registration form","sponsors" => "Sponsor", "chats" => "Chat", "invitee_groups" => "Invitee Group","my_travels" => "My Travel", "maps" => "Map", "course_providers" => "Course Provider","registation_setting" => "Registration Settings","campaigns" => "Campaign","edms" => "eDM","telecaller" =>"Telecaller","registration_look_and_feels" =>"Registration Look and Feel", 'edms' => 'Edm',"maps" => "Map", "folders" => "Folder", "microsites" => "Microsite", "microsite_look_and_feels" => "Look_and_feel", "microsite_features" => "Feature", "microsite_menus" => "Menus", "track_link_users" => "TrackLinkUser", "unsubscribes" => "Unsubscribe", "log_changes" => "LogChange", "consent_questions" => "Consent Questions","mobile_consent_questions" => "Consent Questions", "consent_question_look_and_feels" => "Look and Feel"}
  
  belongs_to :licensee, :foreign_key => :licensee_id, :class_name => 'User'
  has_many :events, :dependent => :destroy
  has_many :mobile_applications, :dependent => :destroy
  has_many :event_groups, :dependent => :destroy
  has_many :microsites, :dependent => :destroy
  has_many :fonts, dependent: :destroy
  #has_many :users
  #has_and_belongs_to_many :users
  
  validates :name,presence: { :message => "This field is required." }, uniqueness: {scope: :licensee_id}
  before_destroy :check_events

  scope :upcoming_event,-> (client){client.events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today) }
  scope :ongoing_event, -> (client){client.events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today) }
  scope :past_event, -> (client){client.events.where('end_event_date < ?',Date.today) }
  scope :ordered, -> { order('created_at desc') }
  
  def self.upcoming_event(client,user,session_role)
    if user.has_role_without_event("event_admin", client,session_role)#user.has_role? :event_admin
      events = Event.with_roles("event_admin", user).where(:client_id => client.id)
      #events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today)
      events.where(:event_category => "Upcoming").where('marketing_app is null')
    elsif user.has_role_without_event("moderator", client,session_role)#user.has_role? :moderator
      events = Event.with_roles("moderator", user).where(:client_id => client.id)
      #events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today)
      events.where(:event_category => "Upcoming").where('marketing_app is null')
    elsif user.has_role_without_event("db_manager", client,session_role)#user.has_role? :db_manager
      events = Client.get_events_for_db_manager(client,user,session_role, category = "Upcoming")
    else
      #client.events.where('start_event_date > ? and end_event_date > ?',Date.today, Date.today)
      client.events.where(:event_category => "Upcoming").where('marketing_app is null')
    end
  end

  def self.ongoing_event(client,user,session_role)
    if user.has_role_without_event("event_admin", client,session_role)#user.has_role? :event_admin
      events = Event.with_roles("event_admin", user).where(:client_id => client.id)
      #events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today)
      events.where(:event_category => "Ongoing").where('marketing_app is null')
    elsif user.has_role_without_event("moderator", client,session_role)#user.has_role? :moderator
      events = Event.with_roles("moderator", user).where(:client_id => client.id)
      #events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today)
      events.where(:event_category => "Ongoing").where('marketing_app is null')
    elsif user.has_role_without_event("db_manager", client,session_role)#user.has_role? :db_manager
      events = Client.get_events_for_db_manager(client,user,session_role, category = "Ongoing")
    else
      #client.events.where('start_event_date <= ? and end_event_date >= ?',Date.today, Date.today)
      client.events.where(:event_category => "Ongoing").where('marketing_app is null')
    end
  end

  def self.past_event(client,user,session_role)
    if user.has_role_without_event("event_admin", client,session_role)#user.has_role? :event_admin
      events = Event.with_roles("event_admin", user).where(:client_id => client.id)
      #events.where('end_event_date < ?',Date.today)
      events.where(:event_category => "Past").where('marketing_app is null')
    elsif user.has_role_without_event("moderator", client,session_role)#user.has_role? :moderator
      events = Event.with_roles("moderator", user).where(:client_id => client.id)
      #events.where('end_event_date < ?',Date.today)
      events.where(:event_category => "Past").where('marketing_app is null')
    elsif user.has_role_without_event("db_manager", client,session_role)#user.has_role? :db_manager
      events = Client.get_events_for_db_manager(client,user,session_role, category = "Past")
    else
      #client.events.where('end_event_date < ?',Date.today)
      client.events.where(:event_category => "Past").where('marketing_app is null')
    end
  end

  aasm :column => :status do  # defaults to aasm_state
    state :active, :initial => true
    state :deactive

    event :deactive do
      transitions :from => [:active], :to => [:deactive]
    end
    event :active do
      transitions :from => [:deactive], :to => [:active]
    end
  end

  def check_events
    return false if self.events.present?
  end
  
  def self.search(params,clients)
    keyword = params[:search][:keyword]
    clients = clients.where("clients.name like (?) ", "%#{keyword}%") if keyword.present?
    clients
  end

  def change_status(client)
    if client == "active"
      self.active!
    elsif client == "deactive"
      self.deactive!
    end
  end

  def self.display_hsh 
    {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client', 'events' => 'Event', 'speakers' => 'Speakers', 'invitees' => 'Invitees', 'agendas' => 'Agenda', 'polls' => 'Polls', 'conversations' => 'Conversations', 'faqs' => 'FAQ', 'images' => 'Gallery', 'awards' => 'Awards', 'qnas' => 'Q&A','feedbacks' => 'Feedback', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlights', 'abouts' => 'About', 'notifications' => 'Notification', 'venue' => 'Venue', 'emergency_exit' => 'Venue','emergency_exits' => 'Venue', 'event_features' => 'Menu', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Notes', 'highlight_images' => 'Highlight Images', 'themes' => 'Theme', 'panels' => 'Panel', "store_infos" => "Store Info", "sponsors" => "Sponsors", "my_profiles" => "My Profile", "qr_codes" => "QR Code Scanner", "my_profile" => "My Profile", "qr_code" => "QR Code Scanner","my_calendar" => "My Calendar", "groupings" => "Grouping","quizzes" => "Quiz","registrations"=> "Registration", "exhibitors" => "Exhibitor","registrations"=> "Registration","invitee_structures"=> "Database","favourites" => "My Favourites","networks" => "My Network","exhibitors" => "Exhibitors", "invitee_datas" => "Dashboard", "conversation_walls" => "View conversation wall", "poll_walls" => "View poll wall","qna_walls" => "View Q&A wall","registration_settings"=> "Registration Setting", 'leaderboard' => 'Leaderboard', 'custom_page1s' => 'Custom Page1', 'custom_page2s' => 'Custom Page2', 'custom_page3s' => 'Custom Page3', 'custom_page4s' => 'Custom Page4', 'custom_page5s' => 'Custom Page5', 'custom_page6s' => 'Custom Page6', 'custom_page7s' => 'Custom Page7', 'custom_page8s' => 'Custom Page8', 'custom_page9s' => 'Custom Page9', 'custom_page10s' => 'Custom Page10', 'analytics' => "Analytics", "leaderboards" => "Leaderboards", "chats" => "One on One Chat", "invitee_groups" => "Invitee Group","my_travels" => "My Travel",'user_registrations' => 'User Registration',"social_sharings" => "Social Sharing","manage_invitee_fields" => "Manage Invitee Fields", 'activity_feeds' => "Activity Feed","all_events" => "Event Listing","qna_settings" => "Qna Setting","registration_look_and_feels" => "Registration look and feel","registration_details" => "registration details","telecaller_dashboards"=>"Telecaller","campaigns" => "Campaign","edms" => "eDM","unsubscribes" => "Unsubscribe","qr_scanner_details" => "Qr Scanner","badge_pdfs" => "Badge","registration_statistics" => "Statistics","maps" => "Map","import_data_api"=> "Database", "folders" => "Folder", "microsites" => "Microsite", "multi_lng_events" => "Multi Lng Events", "unsubscribes" => "Unsubscribe", "log_changes" => "LogChange","mobile_consent_questions" => "Consent Questions", "consent_questions" => "Consent Questions", "consent_question_look_and_feels" => "Look and Feel", 'imports' => 'Excel Imports'}
  end

  def self.display_hsh1 
    {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client', 'events' => 'Event', 'speakers' => 'Speakers', 'invitees' => 'Invitees', 'agendas' => 'Agenda', 'polls' => 'Polls', 'conversations' => 'Conversations', 'faqs' => 'FAQ', 'images' => 'Gallery', 'awards' => 'Awards', 'qnas' => 'Q&A','feedbacks' => 'Feedback', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlights', 'abouts' => 'About', 'notifications' => 'Notification', 'venue' => 'Venue', 'emergency_exit' => 'Venue', 'event_features' => 'Menu', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Notes', 'highlight_images' => 'Highlight Images', 'themes' => 'Theme', 'panels' => 'Panel', "store_infos" => "Store Info", "sponsors" => "Sponsors", "my_profiles" => "My Profile", "qr_codes" => "QR Code Scanner","my_calendar" => "My Calendar", "my_profile" => "My Profile", "qr_code" => "QR Code Scanner","quizzes" => "Quiz","registrations"=> "Registration", "exhibitors" => "Exhibitor","registrations"=> "Registration","invitee_structures"=> "Database","favourites" => "My Favourites","networks" => "My Network","exhibitors" => "Exhibitors","registration_settings"=> "Registration Setting", 'leaderboard' => 'Leaderboard', 'custom_page1s' => 'Custom Page1', 'custom_page2s' => 'Custom Page2', 'custom_page3s' => 'Custom Page3', 'custom_page4s' => 'Custom Page4', 'custom_page5s' => 'Custom Page5', 'custom_page6s' => 'Custom Page6', 'custom_page7s' => 'Custom Page7', 'custom_page8s' => 'Custom Page8', 'custom_page9s' => 'Custom Page9', 'custom_page10s' => 'Custom Page10', "chats" => "One on One Chat", "invitee_groups" => "Invitee Group","my_travels" => "My Travel","social_sharings" => "Social Sharing", 'activity_feeds' => "Activity Feed","all_events" => "Event Listing","campaigns" => "Campaign","edms" => "eDM","maps" => "Map", "folders" => "Folder", "multi_lng_events" => "Multi Lng Events", "track_link_users" => "TrackLinkUser", "unsubscribes" => "Unsubscribe", "log_changes" => "LogChange", "consent_questions" => "Consent Questions","mobile_consent_questions" => "Consent Questions", "consent_question_look_and_feels" => "Look and Feel"}
  end

  def self.display_hsh2 
    {"agendas" => "Agenda", "speakers" => "Speaker" ,'emergency_exits' => 'Venue', "faqs" => "FAQ", "images" => "Gallery",  "contacts" => "ContactUs", "sponsors" => "Sponsor", "registrations" => "Registration", "custom_page1s" => "Custom Page 1", "custom_page2s" => "Custom Page 2", "custom_page3s" => "Custom Page 3", "custom_page4s" => "Custom Page 4", "custom_page5s" => "Custom Page 5", "custom_page6s" => "Custom Page 6", "custom_page7s" => "Custom Page 7", "custom_page8s" => "Custom Page 8", "custom_page9s" => "Custom Page 9", "custom_page10s" => "Custom Page 10"}
  end
  
  def self.bredcrumb_hsh 
    {'mobile_applications' => 'Mobile Application', 'users' => 'User', 'clients' => 'Client', 'events' => 'Event', 'speakers' => 'Speaker', 'invitees' => 'Invitee', 'agendas' => 'Agenda', 'polls' => 'Poll', 'conversations' => 'Conversation', 'faqs' => 'FAQ', 'images' => 'Gallery', 'awards' => 'Award', 'qnas' => 'Q&A','feedbacks' => 'Feedback', 'e_kits' => 'e-KIT','contacts' => 'Contact Us', 'event_highlights' => 'Event Highlight', 'abouts' => 'About', 'notifications' => 'Notification', 'venue' => 'Venue', 'emergency_exit' => 'Venue','emergency_exits' => 'Venue', 'event_features' => 'Menu', 'winners' => 'Winner', 'galleries' => 'Gallery', 'notes' => 'Note', 'highlight_images' => 'Highlight Image', 'themes' => 'Theme', 'panels' => 'Panel', "store_infos" => "Store Info", "sponsors" => "Sponsor", "my_profiles" => "My Profile", "qr_codes" => "QR Code Scanner", "my_profile" => "My Profile", "qr_code" => "QR Code Scanner","my_calendar" => "My Calendar", "groupings" => "Grouping","quizzes" => "Quiz","registrations"=> "Registration", "exhibitors" => "Exhibitor","registrations"=> "Registration","invitee_structures"=> "Database","favourites" => "My Favourite","networks" => "My Network","exhibitors" => "Exhibitor", "invitee_datas" => "Dashboard", "conversation_walls" => "View conversation wall", "poll_walls" => "View poll wall","qna_walls" => "View Q&A wall", 'leaderboard' => 'Leaderboard' , 'custom_page1s' => 'Custom Page1', 'custom_page2s' => 'Custom Page2', 'custom_page3s' => 'Custom Page3', 'custom_page4s' => 'Custom Page4', 'custom_page5s' => 'Custom Page5', 'custom_page6s' => 'Custom Page6', 'custom_page7s' => 'Custom Page7', 'custom_page8s' => 'Custom Page8', 'custom_page9s' => 'Custom Page9', 'custom_page10s' => 'Custom Page10', "chats" => "One on One Chat", "invitee_groups" => "Invitee Group","my_travels" => "My Travel","social_sharings" => "Social Sharing","manage_invitee_fields" => "Manage Invitee Fields",'user_registrations' => 'User Registrations',"campaigns" => "Campaign","edms" => "eDM","maps" => "Map","import_data_api"=> "Database", "folders" => "Folder", "microsites" => "Microsite", "microsite_look_and_feels" => "Look And Feel", "microsite_features" => "Features", "microsite_menus" => "Menus", "multi_lng_events" => "Multi Lng Events", "track_link_users" => "TrackLinkUser", "unsubscribes" => "Unsubscribe", "log_changes" => "LogChange", "consent_questions" => "Consent Questions","mobile_consent_questions" => "Consent Questions", "consent_question_look_and_feels" => "Look and Feel"}
  end
  
  def self.no_data_message
    No_Data_Hash
  end

  def self.get_redirect_page_url(params,client_id)
    url = admin_client_events_path(:client_id => client_id, :feature => params[:feature]) if ["mobile_applications","users"].exclude? params[:feature]
    url = new_client_event_path(:client_id => client_id) if params[:feature] == "events" and params[:redirect_page] == "new"
    url = admin_client_mobile_applications_path(:client_id => client_id) if params[:feature] == "mobile_applications" and params[:redirect_page] != "new"
    url = admin_client_users_path(:client_id => client_id) if params[:feature] == "users" and params[:role] == 'client_admin'
    url = admin_client_events_path(:client_id => client_id, :feature => "users", :role => "event_admin") if params[:feature] == "users" and params[:role] == 'event_admin'
    url 
  end

  def self.menu_icon
    {"invitees" => "Attendees", "polls" => "Polls", "faqs" => "FAQ", "abouts" => "About", "speakers" => "Speaker", "conversations" => "Conversations", "e_kits" => "Ekit", "awards" => "Awards", "qnas" => "qnas", "About" => "About", "agendas" => "Agenda", "contacts" => "contact", "sponsors" => "Sponsor", "notes" => "Notes", "event_highlights" => "event_highlights", "Faqs" => "FAQ", "galleries" => "Gallery", "emergency_exits" => "emergency_exits", "feedbacks" => "Feedback", "attendees" => "Attendees", "venue" => "Venue", "my_calendar" => "my_calendar", "my_profile" => "my_profile", "quizzes" => "Quiz", "qr_code" => "qr_code", "favourites" => "my_favorite", "exhibitors" => "Exhibitor", 'leaderboard' => 'Leaderboard',"my_travels" => "my_travel","activity_feeds" => "activity_feed","chats" => "one_on_one_chat", "maps" => "Map"}
  end

  def self.get_client_by_id(id)
    self.find_by_id(id)
  end

  def self.get_events_for_db_manager(client,user,session_role,category)
    event_ids = Event.with_role("db_manager", user).where(:client_id => client.id).pluck(:id)
    clients =  Client.with_role(session_role, user)
    if clients.pluck(:id).include? client.id
      event_ids += Event.where(:client_id => client.id).pluck(:id)
    end
    events = Event.where(:id => event_ids, :event_category => category).where('marketing_app is null')
  end
end