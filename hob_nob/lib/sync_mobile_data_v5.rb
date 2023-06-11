module SyncMobileDataV5
  include ApplicationHelper

  AGC_TABLES = [ "agendas", "awards", "contacts", "custom_page1s","custom_page2s","custom_page3s","custom_page4s","custom_page5s","custom_page6s","custom_page7s","custom_page8s" ,"custom_page9s", "custom_page10s", "e_kits", "emergency_exits", "events", "event_features", "exhibitors", "faqs", "feedback_forms", "feedbacks", "highlight_images", "maps", "mobile_applications", "panels", "polls", "qna_settings", "quizzes", "registration_settings", "speakers", "sponsors","themes", "winners"]

  UGC_TABLES = ["conversations", "comments", "qnas"]
  
  INVITEE_TABLES = ["favorites", "invitee_notifications", "my_profiles", "my_travels", "ratings", "user_feedbacks", "user_polls","user_quizzes"]
  DAYS_COUNT = 30

  def self.sync_records(params)
    previous_date_time = params[:previous_date_time].to_time.utc
    key = params[:key]
    hard_refresh = params[:hard_refresh]
 
    invitee = Invitee.find_by_key(params[:key])
    event = Event.find_by_id(params[:event_id])
    mobile_application = MobileApplication.get_mobile_application(params[:mobile_application_code])

    results = get_records(invitee, mobile_application, previous_date_time, event, hard_refresh)
  end  

  def self.get_records(invitee, mobile_application, previous_date_time, event = nil, hard_refresh = nil)
    if event.present? and event.status == "rejected"
      response = []
    elsif event.present? or (mobile_application.application_type == "single event" and not mobile_application.multilingual_app)
      event ||= mobile_application.events.first
      response = get_event_records(event, invitee, previous_date_time, hard_refresh)
    else
      response = get_events(mobile_application, invitee)    
    end
  end

  def self.get_event_records(event, invitee, previous_date_time, hard_refresh=nil)
    response = {}
    visibility_tables = event.visibility_tables
    table_list = AGC_TABLES + UGC_TABLES
    table_list = table_list + INVITEE_TABLES if invitee.present?
    parent_event = event.parent_id.present? ? event : event
    table_list.each do |table_name|
      main_event = ((UGC_TABLES+INVITEE_TABLES).include? table_name) ? parent_event : event
      table_results_array = get_table_records(table_name, main_event, invitee, previous_date_time)
      if invitee.present? and visibility_tables.include? table_name
        table_results_array = get_visibility_records(table_results_array, invitee, get_visiblity_column_name(table_name.classify))
      end
      response[:"#{table_name}"] = table_results_array.active_model_serializer.new(table_results_array, {})
      # response[:"#{table_name}"] = table_results_array.as_json(table_attributes_hash(table_name))
    end
    if (hard_refresh == "true") or (previous_date_time.present? and previous_date_time != "01/01/1990 13:26:00".to_time.utc)
      response[:before] = get_deleted_data(table_list, event, invitee, previous_date_time, hard_refresh) 
    end
    return response
  end

  def self.get_deleted_data(table_list, event, invitee, previous_date_time, hard_refresh=nil)
    response = {}
    table_list.each do |table|
      if (hard_refresh == "true" or previous_date_time < Time.now - DAYS_COUNT.days)
        if table == "events"
          if event.parent_id.present? or (event.present? and event.mobile_application.application_type == "multi event")
            response[:"#{table}"]  = ["#{event.id}"]
          else
            response[:"#{table}"] = ["all"]
          end
        else
          response[:"#{table}"] = ["all"] 
        end
      else
        #response[:"#{table}"] = LogChange.where("created_at > ? and action IN (?) and resourse_type = ? and (user_id  = ? or user_id  = ? or user_id is null)", previous_date_time, ["destroy", "update"], table.classify.constantize, (invitee.id rescue nil), (event.client.licensee_id rescue nil)).pluck(:resourse_id)
        response[:"#{table}"] = LogChange.where("created_at > ? and resourse_type = ? and action IN (?)", previous_date_time, table.classify.constantize, ["destroy", "update"]).pluck(:resourse_id)
      end
    end
    response
  end

  def self.get_table_records(table_name, event, invitee, previous_date_time)
    case 
      when (["themes","events"].include? table_name)
        table_name.classify.constantize.where("id = ? and updated_at >= ?", (table_name == "themes" ? event.theme_id : event.id), previous_date_time)
      when (table_name == "ratings")
        table_name.classify.constantize.where("rated_by = ? and updated_at >= ?", invitee.id, previous_date_time)
      when (table_name == "my_profiles")
        [invitee]
      when (table_name == "conversations" || table_name == "comments")
        if event.parent_id.present?
          records = Conversation.where("event_id = ?  and updated_at >= ? ",event.parent_id, previous_date_time).last(20)
          records = Comment.where("commentable_id IN (?) and commentable_type =? and updated_at >= ?", records.map(&:id), "Conversation", previous_date_time) if table_name == "comments"
          records
        else
          records = Conversation.where("event_id = ?  and updated_at >= ? ",event.id, previous_date_time).last(20)
          records = Comment.where("commentable_id IN (?) and commentable_type =? and updated_at >= ?", records.map(&:id), "Conversation", previous_date_time) if table_name == "comments"
          records
        end
      when (table_name == "mobile_applications")
        [event.mobile_application]
      when (INVITEE_TABLES.include? table_name)
        if event.parent_id.present?
          table_name.classify.constantize.unscoped.where("invitee_id = ? and event_id = ? and updated_at >= ?", invitee.id, event.parent_id, previous_date_time)
        else
          table_name.classify.constantize.unscoped.where("invitee_id = ? and event_id = ? and updated_at >= ?", invitee.id, event.id, previous_date_time)
        end
      when (["feedbacks","polls","quizzes","feedback_forms"].include? table_name)
        if event.parent_id.present?
          table_name.classify.constantize.unscoped.where("event_id = ? and updated_at >= ?", event.parent_id, previous_date_time)
        else
          table_name.classify.constantize.unscoped.where("event_id = ? and updated_at >= ?", event.id, previous_date_time)
        end
      when (table_name == "agendas")
        if event.parent_id.present? 
          ex = table_name.classify.constantize.unscoped.where("event_id = ? and updated_at >= ?", event.id, previous_date_time)
          arr = []
          ex.each do |a|
            if a.speaker_ids.present?
            	a.id = a.parent_id
            	speakers = []
              a.speaker_ids.split(",").each do |id|
                speaker_id = Speaker.find(id).parent_id
                speakers << speaker_id
              end
	            a.speaker_ids = speakers.join(",")
	            arr << a
	          else
	          	a.id = a.parent_id
              arr << a
            end
          end
        else
          table_name.classify.constantize.unscoped.where("event_id = ?  and updated_at >= ? ", event.id, previous_date_time)
        end  
      when (["speakers","sponsors","exhibitors"].include? table_name)
        if event.parent_id.present?
          ex = table_name.classify.constantize.unscoped.where("event_id = ? and updated_at >= ?", event.id, previous_date_time)
          arr = []
          ex.each do |a|
            a.id = a.parent_id
            arr << a
          end
        else
          table_name.classify.constantize.unscoped.where("event_id = ? and updated_at >= ?", event.id, previous_date_time)
        end          
      else
        table_name.classify.constantize.unscoped.where("event_id = ?  and updated_at >= ? ", event.id, previous_date_time)
      end
  end

  def self.get_visibility_records(records, invitee, group_field_name)
    invitee_group_ids = invitee.get_invitee_groups
    group_records = records.where("#{group_field_name} = 'all'")
    records.where("#{group_field_name} = 'group'").each do |record|
      if (record.group_ids & invitee_group_ids).present?
        group_records << record
      end
    end
    group_records
  end

  def self.get_events(mobile_application, invitee = nil)
    response = {}
    response["events"] = mobile_application.fetch_events(invitee).active_model_serializer.new(mobile_application.fetch_events(invitee), {})
    response["mobile_applications"] = [mobile_application].active_model_serializer.new([mobile_application], {})
    response
  end

  # Not in use since api is integrated using active model serializers
  # can be used to refer key given to mobile
  
  # def self.table_attributes_hash(model_name)
  #   model_hash = {
  #     "agendas" => {:except =>[:group_ids], :methods =>[:agenda_track_name, :track_sequence, :formatted_start_date_detail, :formatted_time, :formatted_start_date_listing, :formatted_time_without_timezone]},
  #     "analytics" => {},
      
  #     "conversations" => {:except => [:image_file_name, :image_content_type, :image_file_size, :json_data], :methods => [:image_url,:company_name,:like_count,:user_name,:comment_count, :formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone, :first_name, :last_name, :profile_pic_url, :share_count]},
  #     "custom_page1s" => {:only => [:id, :open_with]},
  #     "custom_page2s" => {:only => [:id, :open_with]},
  #     "custom_page3s" => {:only => [:id, :open_with]},
  #     "custom_page4s" => {:only => [:id, :open_with]},
  #     "custom_page5s" => {:only => [:id, :open_with]},
  #     "custom_page6s" => {:only => [:id, :open_with]},
  #     "custom_page7s" => {:only => [:id, :open_with]},
  #     "custom_page8s" => {:only => [:id, :open_with]},
  #     "custom_page9s" => {:only => [:id, :open_with]}, 
  #     "custom_page10s" => {:only => [:id, :open_with]},
  #     "emergency_exits" => {:except => [:icon_file_name,:icon_content_type,:icon_file_size,:emergency_exit_file_name, :emergency_exit_content_type, :emergency_exit_size, :uber_link], :methods => [:emergency_exit_url,:icon_url, :attachment_type]},
  #     "events" => {:except => [:multi_city, :city_id, :logo_file_name, :logo_content_type, :logo_file_size,:inside_logo_file_name,:inside_logo_content_type,:inside_logo_file_size,:footer_image_file_name,:footer_image_content_type,:footer_image_file_size], :methods => [:logo_url,:inside_logo_url, :about_date, :event_start_time_in_utc, :display_time_zone, :footer_image_url]},
  #     "event_features" => {:only => [:id,:name,:event_id,:page_title,:sequence, :status, :description, :menu_visibilty, :menu_icon_visibility, :session_to_agenda, :main_icon_updated_at, :menu_icon_updated_at, :show_event_feature], :methods => [:main_icon_url, :menu_icon_url]},
  #     "exhibitors" => {:except => [:updated_at, :created_at, :image_file_name, :image_content_type, :image_file_size], :methods => [:image_url]}, 
  #     "e_kits" => {:only => [:id, :event_id, :name, :created_at, :updated_at, :agenda_id, :sponsor_id, :show_e_kit_feature, :sub_folder], :methods => [:attachment_url, :attachment_type, :folder_name]},
  #     "feedback_forms" => {:except => [:group_ids]},
  #     "favorites" => {:only=> [:id,:invitee_id, :favoritable_id, :favoritable_type, :status, :event_id], :methods => [:image_url]},
  #     "images" => {:only => [:id, :name, :imageable_id, :imageable_type, :image_updated_at], :methods => [:image_url]},
  #     "highlight_images" => {:only => [:id, :name,:event_id, :highlight_image_updated_at], :methods => [:highlight_image_url]},
  #     "invitee_notifications" => {},
  #     "invitees" => {:only => [:id,:name_of_the_invitee, :first_name, :last_name, :company_name,:event_id, :points, :profile_pic_updated_at], :methods => [:profile_pic_url]}, 
  #     "log_changes" => {},
  #     "mobile_applications" => {:only => [:name,:application_type,:client_id,:id,:login_background_color,:message_above_login_page,:registration_message,:registration_link, :login_button_color, :login_button_text_color, :listing_screen_text_color, :social_media_status, :login_background_updated_at, :listing_screen_background_updated_at, :visitor_registration,:social_media_logins, :app_icon_updated_at,:splash_screen_updated_at,:all_events_listing, :url_1_text, :url_1_link, :url_2_text, :url_2_link, :agreeing_terms_and_conditions, :user_agreement_text], :methods => [:app_icon_url, :splash_screen_url, :login_background_url, :listing_screen_background_url, :visitor_registration_background_image_url, :visitor_registration_back_color,:marketing_app_event_id, :data_visible]},
  #     "my_travels" => {:except => [:created_at, :updated_at, :attach_file_content_type, :attach_file_file_name, :attach_file_file_size, :attach_file_2_file_name, :attach_file_2_content_type, :attach_file_2_file_size, :attach_file_3_file_name, :attach_file_3_content_type, :attach_file_3_file_size, :attach_file_4_file_name, :attach_file_4_content_type, :attach_file_4_file_size, :attach_file_5_file_name, :attach_file_5_content_type, :attach_file_5_file_size], :methods => [:attached_url,:attached_url_2,:attached_url_3,:attached_url_4,:attached_url_5, :attachment_type]} ,
  #     "my_profiles" => {:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location,:invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :instagram_id, :points, :created_at, :updated_at, :profile_pic_updated_at, :qr_code_updated_at], :methods => [:qr_code_url,:profile_pic_url, :rank, :feedback_last_updated_at]},
  #     "maps" => {},
  #     "polls" => {:except => [:option010,:group_ids], :methods => [:option_percentage, :option10]},
  #     "panels" => {}, 
  #     "qnas" => {:methods => [:get_speaker_name, :get_user_name, :get_company_name,:formatted_created_at_for_qna, :formatted_updated_at_for_qna, :get_panel_name,:formatted_created_date_for_display,:formatted_updated_date_for_display]},
  #     "quizzes" => {:except => [:group_ids], :methods => [:get_correct_answer_percentage, :get_total_answer, :get_correct_answer_count]},
  #     "user_feedbacks" => {:methods => [:get_event_id]},
  #     "ratings" => {},
  #     "registration_settings" => {},
  #     "speakers" => {:except => [:profile_pic_file_name, :profile_pic_content_type, :profile_pic_file_size,:group_ids], :methods => [:profile_pic_url, :is_rated]},
  #     "themes" => {:except => [:event_background_image_file_name, :event_background_image_content_type, :event_background_image_file_size],:methods => [:event_background_image_url]},
  #     "winners" => {},
  #     "sponsors" => {:except => [:updated_at, :created_at], :methods => [:image_url]},
  #     "user_polls" => {},
  #     "user_quizzes" => {},
  #     "my_profile" => {:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location, :invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :points, :created_at, :updated_at, :profile_pic_updated_at, :qr_code_updated_at, :instagram_id], :methods => [:qr_code_url,:profile_pic_url, :rank, :feedback_last_updated_at, :feedback_last_updated_at_with_event_timezone, :created_at_with_event_timezone, :updated_at_with_event_timezone]}
  #   }
  #   model_hash["#{model_name}"]
  # end

end


# Completed 200 OK in 3435ms (Views: 1238.5ms | ActiveRecord: 86.7ms)

# Completed 200 OK in 22571ms (Views: 10858.7ms | ActiveRecord: 117.0ms)
# Completed 200 OK in 26165ms (Views: 12539.3ms | ActiveRecord: 131.7ms)
# Completed 200 OK in 26860ms (Views: 12866.7ms | ActiveRecord: 114.1ms)


 # Completed 200 OK in 25449ms (Views: 12744.2ms | ActiveRecord: 104.3ms)


#  Completed 200 OK in 23840ms (Views: 11710.4ms | ActiveRecord: 102.5ms)

# Completed 200 OK in 4410ms (Views: 1665.0ms | ActiveRecord: 167.2ms)
# Completed 200 OK in 3143ms (Views: 2795.0ms | ActiveRecord: 303.6ms)

# with serializer
# Completed 200 OK in 3802ms (Views: 3325.6ms | ActiveRecord: 182.7ms)

# with as_json
# Completed 200 OK in 5663ms (Views: 1882.8ms | ActiveRecord: 237.1ms)


# Completed 200 OK in 8041ms (Views: 3829.3ms | ActiveRecord: 3687.6ms)

# Completed 200 OK in 20938ms (Views: 3397.4ms | ActiveRecord: 1326.5ms)
