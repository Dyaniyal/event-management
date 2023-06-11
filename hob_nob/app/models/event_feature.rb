class EventFeature < ActiveRecord::Base
  include AASM
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  serialize :group_ids, Array
  belongs_to :event

  has_attached_file :menu_icon, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(FEATURE_MENU_ICON_IMAGE_PATH)

  has_attached_file :main_icon, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(FEATURE_MAIN_ICON_IMAGE_PATH)                                         
  attr_accessor :homepage_feature_name
  validates_attachment_content_type :menu_icon, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :main_icon, :content_type => ["image/png"],:message => "please select valid format."
  validate :image_dimensions
  # validate :feature_visibility
  before_save :set_interpolate_time_stamp
  after_create :update_visibility,:create_default_invitee_groups
  # after_create :update_visibility
  after_destroy :update_menu_saved_field_when_no_feature_selected, :update_points
  # after_update :update_menu_icon_for_emergency_exit
  before_save :set_menu_icon_visibility,:rename_main_or_menu_icon_name
  after_save :venue_menu_icon_selection, :update_last_updated_model, :update_event_activity_feed, :clear_cache
  after_save :update_image_setting_for_multi_lang
  #before_save :exclude_zero_from_group_id
  after_destroy :delete_default_invitee_groups, :hide_event_activity_feed, :clear_cache
  after_destroy :remove_multi_lng_event_data
  after_create :update_multi_lng_model_data 
  
  default_scope { order("sequence") }
  scope :not_hidden_icon, -> { where(menu_visibilty: "active",status: "active") }

  aasm :column => :status do  # defaults to aasm_state
    state :active, :initial => true
    state :deactive
    
    event :active do
      transitions :from => [:deactive], :to => [:active]
    end 
     event :deactive do
      transitions :from => [:active], :to => [:deactive]
    end
  end 

  Paperclip.interpolates :interpolate_time_stamp  do |attachment, style|
    attachment.instance.interpolate_time_stamp.to_s
  end

  Paperclip.interpolates :main_icon_interpolate_time_stamp  do |attachment, style|
    attachment.instance.main_icon_interpolate_time_stamp.to_s
  end

  def update_image_setting_for_multi_lang
    if self.parent_id.blank?
      multilingual_event_features = EventFeature.where(parent_id: self.id)
      if multilingual_event_features.present?
        multilingual_event_features.each do |event_feature|
          event_feature.image_setting = self.image_setting
          event_feature.menu_icon_visibility = self.menu_icon_visibility
          event_feature.session_to_agenda = self.session_to_agenda
          event_feature.save
        end
      end
    end
  end

  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove speaker of multilingual events if parent speaker delete.
    end  
  end  
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end 
  
  def update_event_activity_feed
    if (self.status == "deactive" or self.menu_visibilty == "inactive") 
      self.hide_event_activity_feed
    end
  end

  def clear_cache
    #Rails.cache.delete("event_features_json_#{self.event.mobile_application_id}_#{published}")
    #Rails.cache.delete("event_features_json_#{self.event.mobile_application_id}_#{approved_published}")
  end

  def hide_event_activity_feed
    self.event.update_column("set_activity_feed_as_homepage", nil) if self.name == "activity_feeds"
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def venue_menu_icon_selection
    if (self.name == "venue" and self.menu_icon_visibility == "no") or (self.name == "contacts" and self.menu_icon_visibility == "no")
      self.update_column(:updated_at, Time.now)
      self.update_column(:main_icon_file_name, nil)
      self.update_column(:main_icon_content_type, nil) 
      self.update_column(:main_icon_file_size, nil)
      self.update_column(:main_icon_updated_at, nil)
    end
  end

  def main_icon_url(style=nil)
    if self.parent_id.present? and not self.main_icon.exists?
      parent = EventFeature.find(self.parent_id)
      style.present? ? parent.main_icon.url(style) : parent.main_icon.url
    else
      style.present? ? self.main_icon.url(style) : self.main_icon.url
    end
  end

  def menu_icon_url(style=nil)
    if self.parent_id.present? and not self.menu_icon.exists?
      parent = EventFeature.find(self.parent_id)
      style.present? ? parent.menu_icon.url(style) : parent.menu_icon.url
    else
      style.present? ? self.menu_icon.url(style) : self.menu_icon.url
    end
  end

  def set_interpolate_time_stamp
    if self.menu_icon_file_name_changed?
      self.interpolate_time_stamp = "/#{Time.now.to_i.to_s}"
    end
    if self.main_icon_file_name_changed?
      self.main_icon_interpolate_time_stamp = "/#{Time.now.to_i.to_s}"
    end
  end

  def set_menu_icon_visibility
    # if ["contacts","venue","event_highlights", 'chats','social_sharings'].include?(self.name)
    if ["contacts","venue","event_highlights",'social_sharings'].include?(self.name)
      self.menu_icon_visibility = "no"
    end    
  end

  def feature_visibility
    errors.add(:group_ids, "This field is required.") if self.show_event_feature == "group"
  end

  def image_dimensions
    if ["event_highlights","contacts","venue"].exclude?(self.name) and self.parent_id.blank?
      if (self.event.default_feature_icon != "owns" and self.event.default_feature_icon != "new_menu") and self.menu_icon_file_name_changed? 
        event_dimension_height_menu_icon, event_dimension_width_menu_icon  = 72.0, 72.0
        dimensions_menu_icon = Paperclip::Geometry.from_file(menu_icon.queued_for_write[:original].path)
        if (dimensions_menu_icon.width != event_dimension_width_menu_icon or dimensions_menu_icon.height != event_dimension_height_menu_icon)
          errors.add(:menu_icon, "Image size should be 72x72px only")
        end
      end
      if self.event.default_feature_icon == "owns"
        if self.menu_icon.present? and self.menu_icon_file_name_changed?
          event_dimension_height_menu_icon, event_dimension_width_menu_icon  = 72.0, 72.0
          dimensions_menu_icon = Paperclip::Geometry.from_file(menu_icon.queued_for_write[:original].path)
          if (dimensions_menu_icon.width != event_dimension_width_menu_icon or dimensions_menu_icon.height != event_dimension_height_menu_icon)
            errors.add(:menu_icon, "Image size should be 72x72px only")
          end
        end  
      end
      if (self.event.default_feature_icon != "owns" and self.event.default_feature_icon != "new_menu") and (self.main_icon_file_name_changed? and self.main_icon_file_name.present? )
        event_dimension_height_main_icon, event_dimension_width_main_icon  = 288.0, 288.0
        dimensions_main_icon = Paperclip::Geometry.from_file(main_icon.queued_for_write[:original].path)
        if (dimensions_main_icon.width != event_dimension_width_main_icon or dimensions_main_icon.height != event_dimension_height_main_icon)
          errors.add(:main_icon, "Image size should be 288x288px only")
        end
      end

      if (self.event.default_feature_icon == "owns")
        if self.main_icon.present? and self.main_icon_file_name_changed?
          event_dimension_height_main_icon, event_dimension_width_main_icon  = 288.0, 288.0
          dimensions_main_icon = Paperclip::Geometry.from_file(main_icon.queued_for_write[:original].path)
          if (dimensions_main_icon.width != event_dimension_width_main_icon or dimensions_main_icon.height != event_dimension_height_main_icon)
            errors.add(:main_icon, "Image size should be 288x288px only")
          end
        end  
      end
    end  
  end

  def create_default_invitee_groups
    invitee_groups = {'polls' => 'No Polls taken', 'feedbacks' => 'No Feedback given', 'quizzes' => 'No Quiz taken', 'qnas' => 'No Q&A Participation', 'conversations' => 'No Participation in Conversations', 'favourites' => 'No Favorites added'}
    if invitee_groups[self.name].present? and InviteeGroup.where(:event_id => self.event_id, :invitee_ids => ['0'], :name => invitee_groups[self.name]).blank?
      invitee_group = InviteeGroup.new(:event_id => self.event_id, :invitee_ids => ['0'], :name => invitee_groups[self.name])
      invitee_group.save
    end
  end

  def delete_default_invitee_groups
    invitee_groups = {'polls' => 'No Polls taken', 'feedbacks' => 'No Feedback given', 'quizzes' => 'No Quiz taken', 'qnas' => 'No Q&A Participation', 'conversations' => 'No Participation in Conversations', 'favourites' => 'No Favorites added'}
    invitee_group = InviteeGroup.where(:event_id => self.event_id, :name => invitee_groups[self.name]).first
    invitee_group.destroy if invitee_group.present?
  end

  def set_status(event_feature)
    self.active! if event_feature== "active"
    self.deactive! if event_feature== "deactive"
  end

  def update_visibility
    #disable_features = ['event_highlights', 'emergency_exits', "my_calendar","chats","social_sharings"]
    if parent_id.nil?
      disable_features = ['event_highlights', 'emergency_exits', "my_calendar","social_sharings"]
      if disable_features.include? self.name
        self.update_column(:menu_visibilty, 'inactive')
      else
        self.update_column(:menu_visibilty, 'active') 
      end
    end
  end

  # def review_status
  #   features_arr = {'menu_icon' => '', 'main_icon' => '', 'page_title' => '', 'sequence' => '', 'menu_visibilty@@active' => '', 'description' => ''}
  #   ReviewStatus.review(self, features_arr)
  # end

  def self.for_sequence_get_model_name
    {"faqs" => "Faq", "speakers" => "Speaker", "winners" => "Winner", "polls" => "Poll", "event_features" => "EventFeature", 'feedbacks' => 'Feedback', "images" => "Image", "quizzes" => "Quiz", "sponsors" => "Sponsor", "exhibitors" => "Exhibitor", "awards" => "Award", 'panels' => 'Panel', 'agenda_tracks' => "AgendaTrack", 'feedback_forms' => 'FeedbackForm', 'folders' => 'Folder'}
  end

  def update_menu_saved_field_when_no_feature_selected
    if self.event.event_features.blank?
      self.event.menu_saved = "false"
      self.event.save
      #self.event.update_column(:default_feature_icon, "custom") rescue nil
    end
  end

  def self.set_icon_to_feature(event,default_icon,change="false")
    features = event.event_features
    if default_icon != "owns" and change == "true" and !(/\A[-+]?\d+\z/ === default_icon)
      default_icon = (default_icon == "custom" ? "new" : default_icon)
      features.each do |feature|
        if ["contacts","venue"].include?(feature.name)
          feature.update(menu_icon: File.new("public/menu_icons/#{default_icon}_icons/#{Client::menu_icon[feature.name]}.png","rb")) rescue nil
        else
          feature.update(menu_icon: File.new("public/menu_icons/#{default_icon}_icons/#{Client::menu_icon[feature.name]}.png","rb"),main_icon: File.new("public/main_icons/#{default_icon}_icons/#{Client::menu_icon[feature.name]}.png","rb")) rescue nil
        end
      end
    elsif default_icon == "owns" and change == "true"
      features.each do |feature|
        feature.menu_icon = nil if ["custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].exclude?(feature.name)
        feature.main_icon = nil if ["custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].exclude?(feature.name)
        feature.save
      end
    elsif((/\A[-+]?\d+\z/ === default_icon) and change == "true")
      icons = IconLibrary.find(default_icon).icons
      features.each do |feature|
        feature.menu_icon = icons.where(:icon_name => feature.name).first.menu_icon if ["social_sharings","event_highlights","maps","my_calendar","custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].exclude?(feature.name)
        feature.main_icon = icons.where(:icon_name => feature.name).first.main_icon if ["contacts","venue","social_sharings","event_highlights","maps","my_calendar","custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"].exclude?(feature.name)
        feature.save
      end if icons.present?
    end
  end

  def update_points
    if false #self.name == "leaderboard"
      event = self.event
      if event.present?
        #query = "UPDATE invitees SET points = 0 WHERE invitees.event_id = #{event.id}"
        #query1 = "UPDATE analytics SET points = 0 where analytics.viewable_type = 'Invitee' AND event_id = #{event.id} AND action = 'Login'"
        #ActiveRecord::Base.connection.execute(query)
        #ActiveRecord::Base.connection.execute(query1)
      end  
    end
  end

  def rename_main_or_menu_icon_name
    if (self.menu_icon_updated_at_changed? and self.menu_icon_file_name.present?)
      extension = File.extname(menu_icon_file_name).downcase
      self.menu_icon_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
    if (self.main_icon_updated_at_changed? and self.main_icon_file_name.present?)
      extension = File.extname(main_icon_file_name).downcase
      self.main_icon_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end 
  end
end
