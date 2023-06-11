class Api::V1::ActivityFeedsController < ApplicationController

  def index
    invitee = Invitee.find(session['invitee_id']) if session['invitee_id'].present?
    event = Event.find(params[:event_id])
    @event_timezone_offset = event.timezone_offset
    @event_display_timezone = event.display_time_zone
    @background_color = event.theme.background_color
    @background_image = event.theme.event_background_image.url if event.theme.event_background_image_file_name.present?
    params[:page] ||= 1
    if false#invitee.present?
      conversation_ids = invitee.conversations.pluck(:id)
      viewable_types = ["Conversation","Notification","InviteeNotification"]
      actions = ["comment", "conversation post", "like", "share", "notification"]
      @analytics = Analytic.where("(invitee_id = ? and viewable_type IN (?) and action IN (?)) or (viewable_type = ? and viewable_id IN (?))", invitee.id,viewable_types,actions, "Conversation", ["like", "comment"]).where("viewable_id is not null").order("created_at desc")
      @analytics = @analytics.paginate(page: params[:page], per_page: 10)
    end
    if event.present? and params[:social].blank?
      ############## old code ######################
      # # @event_analytics = event.analytics.select("distinct viewable_id, viewable_type").where(:viewable_type => ["Conversation","Notification"].where("viewable_id is not null")

      # if event.event_features.not_hidden_icon.pluck(:name).include? "conversations"
      #   # @event_analytics = event.analytics.where(:viewable_type => ["Conversation","Notification"], :action => ["comment", "conversation post", "like", "share", "notification"]).where("viewable_id is not null").order("created_at desc")
      #   @event_analytics = event.analytics.desc_ordered.activity_feed_actions.select("distinct viewable_id, viewable_type, status").where(:viewable_type => ["Conversation","Notification"]).where("viewable_id is not null and status != 'rejected'")
      # else
      #   @event_analytics = event.analytics.where(:viewable_type => ["Notification"]).where("viewable_id is not null").order("created_at desc")
      #   # @event_analytics = event.analytics.select("distinct viewable_id, viewable_type").where(:viewable_type => ["Notification"]).where("viewable_id is not null")
      # end
      # @event_analytics = @event_analytics.paginate(page: params[:page], per_page: 10)
      ##############################################################################
      if event.event_features.not_hidden_icon.pluck(:name).include? "conversations"
        notification_ids = event.analytics.where("viewable_type IN (?)",["Notification","Conversation"]).pluck(:viewable_id)
        ids = get_analytics_ids(notification_ids,event)
        @event_analytics = event.analytics.desc_ordered.activity_feed_actions.include_not_rejected.select("distinct viewable_id, viewable_type, status").where("viewable_id IN(?) OR viewable_type =?",ids,"Conversation")
      else
        notification_ids = event.analytics.where("viewable_type IN (?)","Notification").pluck(:viewable_id)
        ids = get_analytics_ids(notification_ids,event)
        @event_analytics = event.analytics.where("viewable_id IN (?)",ids).order("created_at desc")
      end
      @event_analytics = @event_analytics.paginate(page: params[:page], per_page: 10)
    elsif params[:social].present?
      redirect_to api_v1_event_social_feeds_path(:event_id => params[:event_id])
    end
  end

  def get_analytics_ids(notification_ids,event)
    actions = event.notifications.where("id IN (?)",notification_ids).pluck(:action).uniq.map(&:pluralize)
    actions = actions.map{|x| x == "Venues" ? "Venue" : x == "Custom Page1s" ? "custom_page1s" : x == "Custom Page2s" ? "custom_page2s" : x == "Custom Page3s" ? "custom_page3s" : x == "Custom Page4s" ? "custom_page4s" : x == "Custom Page5s" ? "custom_page5s" : x =="E-Kits" ? "e_kits" : x == "Q&As" ? "qnas" : x == "QR codes" ? "qr_code" : x == "My Favorites" ? "favourites" : x == "Profiles" ? "my_profile" : x == "My Travels" ? "my_travels" : x == "Leaderboards" ? "leaderboard" : x}
    event_features = event.event_features.not_hidden_icon.where("name IN (?)",actions).pluck(:name)
    event_features1 = event_features.map(&:singularize)
    event_features1 = event_features1.map{|x| x == "venue" ? "Venue" : x == "custom_page1" ? "Custom Page1" : x == "custom_page2" ? "Custom Page2" : x == "custom_page3" ? "Custom Page3" : x == "custom_page4" ? "Custom Page4" : x == "custom_page5" ? "Custom Page5" : x == "e_kit" ? "E-Kit" : x == "qna" ? "Q&A" : x == "qr_code" ? "QR code" : x == "favourite" ? "My Favorite" : x == "my_profile" ? "Profile" : x=="my_travel" ? "My Travel" : x == "leaderboard" ? "Leaderboard" : x }
    ids = event.notifications.where("action = ? or action IN (?) or action = ?","Home Page",event_features1,"").pluck(:id)  
    ids
  end
    
end



