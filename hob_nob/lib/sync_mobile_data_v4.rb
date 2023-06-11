module SyncMobileDataV4

  def self.create_record(values, model_name)
    #message = {}
    message = []
    values.each do |value|
      update_data = nil
      if model_name == 'InviteeNotification'
        update_data = InviteeNotification.where(:notification_id => value["notification_id"], :invitee_id => value["invitee_id"]).last
      elsif model_name == 'UserFeedback'
        update_data = UserFeedback.find_or_create_by(:feedback_id => value["feedback_id"], :user_id => value["user_id"], :feedback_form_id => value["feedback_form_id"])
      else
        update_data = get_model_class(model_name).find_by_id(value["id"])
      end
      if !update_data.blank?
        if model_name == 'InviteeNotification'
          update_data.update(params_data(value)) if update_data.present?
        elsif model_name == 'UserFeedback'
          params = params_data(value)
          update_data.update(params.except(:user_id, :feedback_id, :feedback_form_id)) if update_data.present?
          update_data.update_column('updated_at',Time.now)  
        else
          update_data.update(params_data(value)) if update_data.present?
        end
        #message[:message] = (update_data.errors.messages.blank? ? "Updated" : "#{update_data.errors.full_messages.join(",")}") rescue nil
        #message[:data] =  update_data.as_json() rescue nil
        message <<  update_data.as_json() rescue nil
      else
        create_data = get_model_class(model_name).new(params_data(value))
        create_data.save
        #message[:message] = (create_data.errors.messages.blank? ? "Created" : "#{create_data.errors.full_messages.join(",")}") rescue nil
        #message[:data] =  create_data.as_json() rescue nil
        message << create_data.as_json() 
        if model_name == "Qna"
          event = Event.find_by_id(create_data.event_id)
          if (event.qna_settings.present? and event.qna_settings.first.display_qna_on_app.present? and event.qna_settings.first.display_qna_on_app == "yes")
            sender = Invitee.find_by_id(create_data.sender_id)
            receiver = Panel.find_by_id(create_data.receiver_id) 
            UserMailer.send_mail_to_receiver(receiver,sender,event).deliver_now if (sender.present? and receiver.present?)
          end
        end
      end      
    end if values.present?
    return message
  end
  
  def self.delete_record(values, model_name)
    message = []
    if values.present?
      values.each do |value|
        deleted_value = model_name.constantize.find_by_id(value["id"])
        if deleted_value.destroy
          #message << deleted_value.id
          resourse_type = "Favorite" if model_name == "Favorite"
          resourse_type = "Like" if model_name == "Like"
          message << {:action => "destroy","resourse_id" => deleted_value.id,"resourse_type" => resourse_type}
        end if deleted_value.present?
      end
    end  
    return message
  end

  def self.sync_records(params_start_event_date, params_end_event_date,mobile_application_id,current_user,submitted_app, event_ids = nil, all_mobile_event_ids = nil,hard_refresh = nil)
    #email_id = Invitee.find(current_user.id).email
    #current_user = Invitee.where(:event_id => event_ids, :email => email_id)

    start_event_date = params_start_event_date
    end_event_date = params_end_event_date
    event_status = (submitted_app == "Yes" ? ["published"] : ["approved","published"])
    event_status_str = event_status.join("_")
    if event_ids.present?  
      events = Event.where(:id => event_ids)
      all_event_ids = event_ids
    else
      events = Event.where(:mobile_application_id => mobile_application_id, :status =>  event_status)
      event_ids = events.pluck(:id) rescue nil
      latest_published_event_ids = events.where(:published_at => start_event_date...end_event_date).pluck(:id) if submitted_app == "Yes" 
      all_event_ids = latest_published_event_ids.present? ? (event_ids + latest_published_event_ids.to_a).uniq : event_ids  
    end
    if event_ids.present? and event_ids.count == 1
      multilingual_event = Event.where("id =?",event_ids).first rescue nil
      multi_lingual_event_id = (multilingual_event.present? and multilingual_event.parent_id.present?) ? [multilingual_event.parent_id] : []
    end
    model_name = []
    data = {}
    model_name = ActiveRecord::Base.connection.tables.map {|m| m.capitalize.singularize.camelize}
    models_array = ["CkeditorAsset" ,"UserRegistration","SmtpSetting","Grouping","StoreInfo","LoggingObserver","StoreScreenshot","PushPemFile","EventGroup","EventFeatureList","Import","Device","User","Note","EventIcon","EventsUser","AgendasDayoption","ClientsUser","SchemaMigration","UsersRole","Attendee","Client", "City","Dayoption", "Licensee", "Role", "About","Tagging","Tag", 'EventsMobileApplication','PushNotification', 'InviteeStructure', 'InviteeDatum', 'Chat', 'InviteeGroup', 'Campaign', 'EdmMailSent', 'Edm', 'TelecallerAccessibleColumn', 'Gallery', 'CustomPage', 'RegistrationField','Session', 'AgendaTrack', 'BadgePdf', 'LastUpdatedModel', 'Microsite',  'UserMicrosite', 'VenueSection', 'ConversationWall', 'EventVenue', 'PollWall', 'QnaWall', 'QuizWall', 'AgendaSpeaker',"Analytic","CampaignsEvent",'AutoStatusEmail','CampaignsEvent','CourseProvider','CourseTag','Course','InviteeAccess','MyTravelDoc','RegistrationLookAndFeel','TelecallerGroup','TrackLink','Unsubscribe','Folder','ImportApi', 'Microsite', 'MicrositeFeature','MicrositeLookAndFeel']#.each {|value| model_name.delete(value)}
    model_name = model_name - models_array
    
    #commented by Atul on 03-Oct-2018 to eliminate LastUpdatedModel as update_record in last_updated_model.rb was taking long time to process (around 60sec)
    #if latest_published_event_ids.present?
      last_updated_models = LastUpdatedModel.pluck("DISTINCT name")
    #else
    #  last_updated_models = LastUpdatedModel.where(:last_updated => start_event_date..end_event_date).pluck("DISTINCT name")
    #end
    feature_visible_flag = feature_visiblity(event_ids, start_event_date, end_event_date, latest_published_event_ids, "EventFeature", "show_event_feature")
    model_name.each do |model|
      if (model == 'Notification' or model == 'InviteeNotification') and start_event_date.present? and not start_event_date == "01/01/1990 13:26:58".to_time.utc
        start_event_date = params_start_event_date.to_datetime - 5.minutes 
      else
        start_event_date = params_start_event_date
      end
      if last_updated_models.include? model and ((model == "Conversation" or model == "Qna" or model =="QnaSetting") and multilingual_event.present? and multi_lingual_event_id.present?)
        if latest_published_event_ids.present?
          info = self.get_model_class(model).where("(updated_at between ? and ? and event_id IN (?)) or event_id IN (?)", start_event_date, end_event_date, multi_lingual_event_id, latest_published_event_ids)
        else
          info = self.get_model_class(model).where(:updated_at => start_event_date..end_event_date).where(:event_id => multi_lingual_event_id) rescue []
        end      
      elsif last_updated_models.include? model
        if latest_published_event_ids.present?
          info = self.get_model_class(model).where("(updated_at between ? and ? and event_id IN (?)) or event_id IN (?)", start_event_date, end_event_date, event_ids, latest_published_event_ids)
        else
          info = self.get_model_class(model).where(:updated_at => start_event_date..end_event_date).where(:event_id => event_ids) rescue []
        end
      else
        info = []
      end
      case model
        when 'Conversation'
          info = info.where(:status => 'approved').last(20) if info.present?
          data[:"#{name_table(model)}"] = info.as_json(:except => [:image_file_name, :image_content_type, :image_file_size, :json_data], :methods => [:image_url,:company_name,:like_count,:user_name,:comment_count, :formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone, :first_name, :last_name, :profile_pic_url, :share_count])
           conversation_ids = info.map(&:id)
          info = Comment.where(:commentable_id => conversation_ids, commentable_type: "Conversation", :updated_at => start_event_date..end_event_date) rescue []
          #info = Comment.get_comments(conversation_ids,start_event_date, end_event_date) rescue []
          data[:"comments"] = info.as_json(:methods => [:user_name, :formatted_created_at_with_event_timezone, :formatted_updated_at_with_event_timezone, :first_name, :last_name]) rescue []
          if current_user.present?
            info = Like.where(:likable_id => conversation_ids, likable_type: "Conversation", :updated_at => start_event_date..end_event_date) rescue []
            data[:"likes"] = info.as_json() rescue []
          end
        when 'EmergencyExit'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:icon_file_name,:icon_content_type,:icon_file_size,:emergency_exit_file_name, :emergency_exit_content_type, :emergency_exit_size, :uber_link], :methods => [:emergency_exit_url,:icon_url, :attachment_type])
        when 'Event'
          if latest_published_event_ids.present?
            event_info = Event.where("(updated_at between ? and ? and id IN (?)) or id IN (?)", start_event_date, end_event_date, event_ids, latest_published_event_ids)
          else
            event_info = Event.where(:id => event_ids,:updated_at => start_event_date..end_event_date, :status => event_status)
          end
          data[:"#{name_table(model)}"] = event_info.as_json(:except => [:multi_city, :city_id, :logo_file_name, :logo_content_type, :logo_file_size,:inside_logo_file_name,:inside_logo_content_type,:inside_logo_file_size, :footer_image_file_name,:footer_image_content_type,:footer_image_file_size], :methods => [:logo_url,:inside_logo_url, :about_date, :event_start_time_in_utc, :display_time_zone, :footer_image_url])
        when 'EventFeature'
          if current_user.present?
            data1 = get_feaure_data(info, current_user, "show_event_feature")
            data[:"#{name_table(model)}"] = data1.as_json(:only => [:id,:name,:event_id,:page_title,:sequence, :status, :description, :menu_visibilty, :menu_icon_visibility, :session_to_agenda, :main_icon_updated_at, :menu_icon_updated_at, :show_event_feature, :image_setting], :methods => [:main_icon_url, :menu_icon_url])
          elsif feature_visible_flag
            data[:"#{name_table(model)}"] = []
          else
            data[:"#{name_table(model)}"] = info.as_json(:only => [:id,:name,:event_id,:page_title,:sequence, :status, :description, :menu_visibilty, :menu_icon_visibility, :session_to_agenda, :main_icon_updated_at, :menu_icon_updated_at, :show_event_feature, :image_setting], :methods => [:main_icon_url, :menu_icon_url])
          end
        when 'Speaker'
          if current_user.present?
            data1 = get_feaure_data(info, current_user, "show_speaker_feature")
            data[:"#{name_table(model)}"] = data1.as_json(:except => [:profile_pic_file_name, :profile_pic_content_type, :profile_pic_file_size,:group_ids], :methods => [:profile_pic_url, :is_rated])
          elsif feature_visible_flag
            data[:"#{name_table(model)}"] = []
          else
            data[:"#{name_table(model)}"] = info.as_json(:except => [:profile_pic_file_name, :profile_pic_content_type, :profile_pic_file_size,:group_ids], :methods => [:profile_pic_url, :is_rated])
          end
        when 'Image'
          images = Image.where(:updated_at => start_event_date..end_event_date) rescue []
          data[:"#{name_table(model)}"] = images.where(:imageable_id => event_ids, :imageable_type => "Event").as_json(:only => [:id, :name, :imageable_id, :imageable_type, :image_updated_at], :methods => [:image_url, :folder_name, :folder_sequence]) rescue []  
        when 'HighlightImage'
          data[:"#{name_table(model)}"] = info.as_json(:only => [:id, :name,:event_id, :highlight_image_updated_at], :methods => [:highlight_image_url]) rescue []    
        when 'Theme'
          theme_ids = events.pluck(:theme_id)
          if latest_published_event_ids.present?
            updated_theme_ids = Event.where(:id => latest_published_event_ids).pluck(:theme_id)
            themes = Theme.where("(id IN (?) and updated_at between ? and ?) or id IN (?)", theme_ids, start_event_date, end_event_date, updated_theme_ids)
          else
            themes = Theme.where(:id => theme_ids, :updated_at => start_event_date..end_event_date) rescue []
          end
          data[:"#{name_table(model)}"] = themes.as_json(:except => [:event_background_image_file_name, :event_background_image_content_type, :event_background_image_file_size],:methods => [:event_background_image_url]) rescue []  
        when 'Winner'
          award_ids = Award.where(:event_id => event_ids).pluck(:id) rescue nil
          published_award_ids = Award.where(:event_id => latest_published_event_ids).pluck(:id) if latest_published_event_ids.present?
          if published_award_ids.present?
            info = Winner.where("(award_id IN (?) and updated_at between ? and ?) or award_id IN (?)", award_ids, start_event_date, end_event_date, published_award_ids)
          else
            info = Winner.where(:award_id => award_ids, :updated_at => start_event_date..end_event_date)
          end
          data[:"#{name_table(model)}"] = info.as_json()
        when 'Comment'
          # conversation_ids = Conversation.where(:event_id => event_ids, :status => "approved").pluck(:id) rescue nil
        when 'Sponsor'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:updated_at, :created_at], :methods => [:image_url])
        when 'Exhibitor'
          data[:"#{name_table(model)}"] = info.as_json(:except => [:updated_at, :created_at, :image_file_name, :image_content_type, :image_file_size], :methods => [:image_url])
        when 'Notification'
          info = Invitee.get_notification(info, event_ids, current_user, start_event_date, end_event_date)
          data[:"notifications"] = info
        when 'InviteeNotification'
          info = Invitee.get_read_notification(info, event_ids, current_user)
          data[:"invitee_notifications"] = info
        when 'Poll'
          polls = info
          if current_user.present?
            data1 = get_feaure_data(info, current_user, "show_poll_feature")
            data[:"#{name_table(model)}"] = data1.as_json(:except => [:option010,:group_ids], :methods => [:option_percentage, :option10]) rescue []
          elsif feature_visible_flag
            data[:"#{name_table(model)}"] = []
          else
            data[:"#{name_table(model)}"] = info.as_json(:except => [:option010,:group_ids], :methods => [:option_percentage, :option10]) rescue []
          end
        when 'Invitee'
          arr = []
          leaders = Invitee.unscoped.where(:event_id => event_ids, :visible_status => 'active').order('points desc') rescue []
          event_ids.map{|id| arr = arr + leaders.where(:event_id => id).order('points desc').first(5).as_json(:only => [:id,:name_of_the_invitee, :first_name, :last_name, :company_name,:event_id, :points, :profile_pic_updated_at], :methods => [:profile_pic_url])}
          data[:"leaderboard"] = arr#event_ids.map{|id| {'id' => id, 'data'=> leaders.where(:event_id => id).order('points desc').first(5).as_json(:only => [:id,:name_of_the_invitee,:company_name,:event_id, :points], :methods => [:profile_pic_url])}}
          if current_user.present? and (start_event_date != "01/01/1990 13:26:58".to_time.utc)
            # my_profiles = Invitee.where("event_id IN (?) and email = ?",event_ids, current_user.email) rescue nil
            my_profiles = current_user.get_similar_invitees(event_ids)
            my_profiles = my_profiles.where(:updated_at => start_event_date..end_event_date) if my_profiles.present?
          data[:"invitees"] = my_profiles.as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location,:invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :instagram_id, :points, :created_at, :updated_at, :profile_pic_updated_at, :qr_code_updated_at], :methods => [:qr_code_url,:profile_pic_url, :rank, :feedback_last_updated_at])
          data[:"all_feedback_forms_last_updated_at"] = current_user.all_feedback_forms_last_updated_at_on_time_basis(nil, nil, all_event_ids,start_event_date,end_event_date)
            # invitee_ids = Invitee.where("event_id IN (?) and email =?", event_ids, current_user.email).pluck(:id) rescue nil
            invitee_ids = current_user.get_similar_invitees(event_ids).pluck(:id)
            ids = Favorite.where(:invitee_id => invitee_ids, :updated_at => start_event_date..end_event_date).pluck(:favoritable_id) rescue [] 
            info = Invitee.where(:id => ids) rescue []
            data[:"my_network_invitee"] = info.as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location,:invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :instagram_id, :profile_pic_updated_at, :qr_code_updated_at], :methods => [:qr_code_url,:profile_pic_url]) rescue []
          end
        when 'Quiz'
          quizzes = info
          if current_user.present?
            data1 = get_feaure_data(info, current_user, "show_quiz_feature")
            data[:"#{name_table(model)}"] = data1.as_json(:except => [:group_ids], :methods => [:get_correct_answer_percentage, :get_total_answer, :get_correct_answer_count]) rescue []  
          elsif feature_visible_flag
            data[:"#{name_table(model)}"] = []
          else
            data[:"#{name_table(model)}"] = info.as_json(:except => [:group_ids], :methods => [:get_correct_answer_percentage, :get_total_answer, :get_correct_answer_count]) rescue []  
          end
          
          # data[:"#{name_table(model)}"] = info.as_json(:methods => [:get_correct_answer_percentage, :get_total_answer, :get_correct_answer_count]) rescue []  
        when 'LogChange'
          if not (start_event_date == "01/01/1990 13:26:58".to_time.utc)
            # info = LogChange.where(:created_at => start_event_date..end_event_date , :action => "destroy", :user_id => current_user.present? ? current_user.id : '')
            info = LogChange.where('created_at BETWEEN ? AND ?',start_event_date, end_event_date).where("action = ? and (user_id = ? or user_id =?)", "destroy", (current_user.present? ? current_user.id : ''), (events.first.client.licensee_id rescue ''))
            #info = LogChange.where('created_at  >?',start_event_date).where(:action => "destroy")
            data[:"#{name_table(model)}"] = get_deleted_records_for_data_visibility(mobile_application_id, current_user, info)#info.as_json(:only => [:resourse_type,:resourse_id,:updated_at,:action]) rescue []
          elsif (hard_refresh.present? and hard_refresh == "true")
            start_event_date = (Time.now.utc - 60.minutes)
            # start_event_date = "01/01/1990 13:26:58".to_time.utc 
            info = LogChange.where('created_at > ?',start_event_date).where("action = ? and (user_id = ? or user_id =?)","destroy", (current_user.present? ? current_user.id : ''), (events.first.client.licensee_id rescue ''))
            data[:"#{name_table(model)}"] = get_deleted_records_for_data_visibility(mobile_application_id, current_user, info)#info.as_json(:only => [:resourse_type,:resourse_id,:updated_at,:action]) rescue []
          else
            info = get_deleted_records_for_data_visibility(mobile_application_id, current_user)
            data[:"#{name_table(model)}"] = info
          end
        when 'Favorite'
          if current_user.present?
            # invitee_ids = Invitee.where("event_id IN (?)0 and email =?", event_ids, current_user.email).pluck(:id) rescue nil
            invitee_ids = current_user.get_similar_invitees(event_ids).pluck(:id)
            info = Favorite.where(:invitee_id => invitee_ids, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json(:only=> [:id,:invitee_id, :favoritable_id, :favoritable_type, :status, :event_id], :methods => [:image_url]) rescue []
          end
        when 'Like'
          # if current_user.present?
          #   conversation_ids = Conversation.where(:event_id => event_ids) rescue nil
          #   info = Like.where(:likable_id => conversation_ids, likable_type: "Conversation", :updated_at => start_event_date..end_event_date) rescue []
          #   data[:"#{name_table(model)}"] = info.as_json() rescue []
          # end
        when 'UserPoll'
          if current_user.present?
            polls = Poll.where(:event_id => event_ids) if polls.blank?
            info = UserPoll.where(user_id: current_user.id, :poll_id => polls.pluck(:id), :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end
        when 'UserQuiz'
          if current_user.present?
            quizzes = Quiz.where(:event_id => event_ids) rescue nil if quizzes.blank?
            info = UserQuiz.where(user_id: current_user.id, :quiz_id => quizzes.pluck(:id), :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end  
        when 'Rating'
          if current_user.present?
            speaker_ids = Speaker.where(:event_id => event_ids) rescue nil
            agenda_ids = Agenda.where(:event_id => event_ids) rescue nil
            sponsor_ids = Sponsor.where(:event_id => event_ids) rescue nil
            info = Rating.where(:ratable_id => [speaker_ids,agenda_ids,sponsor_ids].flatten, :updated_at => start_event_date..end_event_date, :rated_by => current_user.id) rescue []
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end
        when 'Qna'
          info = info.where(:status => 'approved') if info.present?
          data[:"#{name_table(model)}"] = info.as_json(:methods => [:get_speaker_name, :get_user_name, :get_company_name,:formatted_created_at_for_qna, :formatted_updated_at_for_qna,:invitee_profile_pic,:get_panel_name,:formatted_created_date_for_display,:formatted_updated_date_for_display]) rescue []
        when 'UserFeedback'  
          if current_user.present?
            feedback_ids = Feedback.where(:event_id => event_ids) rescue nil
            feedback_ids = get_feaure_data(feedback_ids, current_user, "show_feedback_feature")
            info = UserFeedback.where(user_id: current_user.id, :feedback_id => feedback_ids, :updated_at => start_event_date..end_event_date) rescue []
            data[:"#{name_table(model)}"] = info.as_json(:methods => [:get_event_id]) rescue []
          end
        when "MobileApplication"  
          if start_event_date != "01/01/1990 13:26:58".to_time.utc or submitted_app != "Yes"
            mobile_application_ids = events.pluck(:mobile_application_id) rescue nil
            if mobile_application_ids.present?
              info = MobileApplication.where(:id => mobile_application_ids, :updated_at => start_event_date..end_event_date) rescue [] 
            else
              info = MobileApplication.where(:id => mobile_application_id, :updated_at => start_event_date..end_event_date) rescue []
            end
            data[:"#{name_table(model)}"] = info.as_json(:only => [:name,:application_type,:client_id,:id,:login_background_color,:message_above_login_page,:registration_message,:registration_link, :login_button_color, :login_button_text_color, :listing_screen_text_color, :social_media_status, :login_background_updated_at, :listing_screen_background_updated_at, :visitor_registration,:social_media_logins, :app_icon_updated_at,:splash_screen_updated_at,:all_events_listing, :url_1_text, :url_1_link, :url_2_text, :url_2_link, :agreeing_terms_and_conditions, :user_agreement_text], :methods => [:app_icon_url, :splash_screen_url, :login_background_url, :listing_screen_background_url, :visitor_registration_background_image_url, :visitor_registration_back_color,:marketing_app_event_id, :data_visible, :multilingual_app]) rescue []
          end
        when 'MyTravel'  
          if current_user.present?
            invitee_ids = Invitee.where(:event_id => event_ids, :email => current_user.email).pluck(:id)
            info = info.where(:invitee_id => invitee_ids) if info.present?
            data[:"#{name_table(model)}"] = info.as_json(:except => [:created_at, :updated_at, :attach_file_content_type, :attach_file_file_name, :attach_file_file_size, :attach_file_2_file_name, :attach_file_2_content_type, :attach_file_2_file_size, :attach_file_3_file_name, :attach_file_3_content_type, :attach_file_3_file_size, :attach_file_4_file_name, :attach_file_4_content_type, :attach_file_4_file_size, :attach_file_5_file_name, :attach_file_5_content_type, :attach_file_5_file_size], :methods => [:attached_url,:attached_url_2,:attached_url_3,:attached_url_4,:attached_url_5, :attachment_type]) rescue []
          end
        when 'EKit' 
          info = EKit.get_e_kits_all_events_v4(event_ids, start_event_date, end_event_date, latest_published_event_ids, current_user)
          if current_user.present?
            # data1 = get_e_kit_feature_data(info, current_user)
            # data1 = get_feaure_data(info, current_user, "show_e_kit_feature")
            data[:"#{name_table(model)}"] = info rescue []
          elsif feature_visible_flag
            data[:"#{name_table(model)}"] = []
          else
            data[:"#{name_table(model)}"] = info rescue []
          end
        when 'Analytic'  
          if current_user.present?
            # user_ids = Invitee.where("event_id IN (?) and  email = ?",event_ids, current_user.email).pluck(:id) rescue nil
            user_ids = current_user.get_similar_invitees(event_ids).pluck(:id)
            analytics = Analytic.where("event_id IN (?) and viewable_type = ? and invitee_id IN (?) and viewable_id IS NOT NULL",event_ids, 'E-Kit', user_ids).where(:updated_at => start_event_date..end_event_date) rescue []
            info = analytics.as_json() rescue []
            data[:"#{name_table(model)}"] = info
          end
        when "Agenda"
           info = self.get_model_class(model).where(:event_id => event_ids) rescue []
          if current_user.present?
            data1 = get_feaure_data(info, current_user, "show_agenda_feature")
            data[:"#{name_table(model)}"] = data1.as_json(:except =>[:group_ids],:methods =>[:agenda_track_name, :track_sequence, :formatted_start_date_detail, :formatted_time, :formatted_start_date_listing, :formatted_time_without_timezone])
          elsif feature_visible_flag
            data[:"#{name_table(model)}"] = []
          else
            data[:"#{name_table(model)}"] = info.as_json(:except =>[:group_ids],:methods =>[:agenda_track_name, :track_sequence, :formatted_start_date_detail, :formatted_time, :formatted_start_date_listing, :formatted_time_without_timezone])
          end
        when "MyProfile"
          if (current_user.present? and start_event_date != "01/01/1990 13:26:58".to_time.utc)
            mobile_application = MobileApplication.find_by_id(mobile_application_id) if mobile_application_id.present?
            if (mobile_application.application_type.present? and mobile_application.application_type == "multi event") 
              mobile_app_submitted_code = mobile_application.submitted_code if mobile_application.present?
              info = current_user.get_my_profiles(mobile_app_submitted_code,submitted_app,start_event_date,end_event_date) if mobile_app_submitted_code.present?
              data[:"#{name_table(model)}"] = info
            end
          end
        when "Panel"
          info = Panel.where(:event_id => event_ids, :updated_at => start_event_date..end_event_date) 
          # info = info.where(:hide_panel => "deactive") if info.present?
          data[:"#{name_table(model)}"] = info.as_json() rescue []
        when "Map"
          info = Map.where(:event_id => event_ids) 
          data[:"#{name_table(model)}"] = info.as_json() rescue []
        when "RegistrationSetting"
          if (event_ids.present? and event_ids.include?(0))
            mobile_application = MobileApplication.find_by_id(mobile_application_id) if mobile_application_id.present?
            events = (mobile_application.present? and mobile_application.events.present?) ? (mobile_application.events.where('status IN (?)',event_status)) : []
            registration_setting = (events.present?) ? (RegistrationSetting.where('event_id IN (?)',events.pluck(:id)).present? ? ([RegistrationSetting.where('event_id IN (?)',events.pluck(:id)).first]) : []) : []
            info = registration_setting.as_json()
            data[:"#{name_table(model)}"] = info
          else
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end
        when 'FeedbackForm'
          if current_user.present?
            data1 = get_feaure_data(info, current_user, "show_feedback_feature")
            data[:"#{name_table(model)}"] = data1.as_json(:except => [:group_ids]) rescue []
          elsif feature_visible_flag
            data[:"#{name_table(model)}"] = []
          else
            data[:"#{name_table(model)}"] = info.as_json(:except => [:group_ids]) rescue []
          end
        else
          if ['CustomPage1', 'CustomPage2', 'CustomPage3', 'CustomPage4', 'CustomPage5', 'CustomPage6', 'CustomPage7', 'CustomPage8', 'CustomPage9', 'CustomPage10'].include? model
            tmp_arr = []
            info.each do |x|
              x.site_url = site_url_custom(x)
              tmp_arr << x
            end
            data[:"#{name_table(model)}"] = tmp_arr.as_json() rescue []
          else
            data[:"#{name_table(model)}"] = info.as_json() rescue []
          end
      end  
    end
    return data
  end  

  def self.name_table(model)
    return model == "Agenda" ? model.constantize.table_name.singularize : model.constantize.table_name
  end

  def self.get_model_class(model)
    case model
      when 'Conversation'
        Conversation
      when 'EmergencyExit'
        EmergencyExit
      when 'Event'
        Event
      when 'EventFeature'
        EventFeature
      when 'Speaker'
        Speaker
      when 'Image'
        Image  
      when 'HighlightImage'
        HighlightImage
      when 'Theme'
        Theme
      when 'Winner'
        Winner
      when 'Comment'
        Comment
      when 'Sponsor'
        Sponsor
      when 'Exhibitor'
        Exhibitor
      when 'Notification'
        Notification
      when 'InviteeNotification'
        InviteeNotification
      when 'Poll'
        Poll
      when 'Invitee'
        Invitee
      when 'Quiz'
        Quiz
      when 'LogChange'
        LogChange
      when 'Favorite'
        Favorite
      when 'Like'
        Like
      when 'UserPoll'
        UserPoll
      when 'UserQuiz'
        UserQuiz
      when 'Rating'
        Rating
      when 'Qna'
        Qna
      when 'UserFeedback'  
        UserFeedback
      when "MobileApplication"  
        MobileApplication
      when 'MyTravel'  
        MyTravel
      when 'EKit' 
        EKit
      when 'Analytic'  
        Analytic
      when "Agenda"
        Agenda
      when "Panel"
        Panel
      when "Map"
        Map
      else
        model.constantize
    end  

  end

  # def self.get_feaure_data(info, current_user, speaker_data)
  #   data1 = []
  #   info.each do |i|
  #     if i.send(speaker_data) == "group" 
  #       invitee_ids = InviteeGroup.where("id in (?)",i.group_ids).map{|x| x.get_invitee_ids}.flatten
  #       data1 << i if invitee_ids.include? current_user.id.to_s rescue []
  #     else
  #       data1 << i
  #     end
  #   end
  #   data1
  # end

  #this method is deprecated use get_feature_data
  def self.get_feaure_data(info, current_user, speaker_data)
    if current_user.present?
      invitee = current_user 
      group_field_name = speaker_data
      records = info
      get_feature_data(records, invitee, group_field_name)
    else
      []
    end
  end

  def self.get_invitee_groups(invitee)
    invitee_group_ids =[]
    invitee.event.invitee_groups.each do |ig|
      if ig.invitee_ids.include? invitee.id.to_s
        invitee_group_ids << ig.id.to_s
      end
    end
    invitee_group_ids
  end

  def self.get_feature_data(records, invitee, group_field_name)
    invitee_group_ids = get_invitee_groups(invitee)
   
    group_records = []
    records.each do |record|
      if record.send(group_field_name) == "group" 
        if (record.group_ids & invitee_group_ids).present?
          group_records << record 
        end
      else
        group_records << record 
      end
    end
    group_records
  end

  def self.params_data(value)
    # if value.key?(:feedback_id) and value.key?(:user_id)
    #   return value.except(:id,:created_at).permit!
    # else
      return value.except(:id,:created_at,:updated_at).permit!
    # end
  end

  def self.select_model(key,value,platform)
    allow_analytics = ["Note","Poll","Feedback","MyProfile","Quiz","Invitee","Analytic"]
    chanages_done = []
    if value.present?
      value.each do |v|
        v[:platform] = platform
      end if allow_analytics.exclude?(key)
    end
    case key
      when "Note"
        chanages_done = SyncMobileData.create_record(value,"Note")
      when "Rating" 
        chanages_done = SyncMobileData.create_record(value,"Rating")
      when "Qna" 
        chanages_done = SyncMobileData.create_record(value,"Qna")  
      when "Comment" 
        chanages_done = SyncMobileData.create_record(value,"Comment")
      when "Conversation" 
        chanages_done = SyncMobileData.create_record(value,"Conversation") 
      when "Poll" 
        chanages_done = SyncMobileData.create_record(value,"Poll")
      when "UserPoll" 
        chanages_done = SyncMobileData.create_record(value,"UserPoll")  
      when "Favorite"
        chanages_done = SyncMobileData.create_record(value,"Favorite")
      when "Like"
        chanages_done = SyncMobileData.create_record(value,"Like")
      when "Feedback"
        chanages_done = SyncMobileData.create_record(value,"Feedback")
      when "UserFeedback"
        chanages_done = SyncMobileData.create_record(value,"UserFeedback") 
      when "MyProfile"
        chanages_done = SyncMobileData.create_record(value,"Invitee") 
      when "Quiz" 
        chanages_done = SyncMobileData.create_record(value,"Quiz")
      when "UserQuiz" 
        chanages_done = SyncMobileData.create_record(value,"UserQuiz")
      when "Invitee" 
        chanages_done = SyncMobileData.create_record(value,"Invitee")  
      when "Analytic" 
        chanages_done = SyncMobileData.create_record(value,"Analytic")  
      when "InviteeNotification" 
        chanages_done = SyncMobileData.create_record(value,"InviteeNotification")  
      end
    chanages_done  
  end

  def self.feature_visiblity(event_ids, start_event_date, end_event_date, latest_published_event_ids, model, column_name)
    if latest_published_event_ids.present?
      info = self.get_model_class(model).where("(updated_at between ? and ? and event_id IN (?)) or event_id IN (?)", start_event_date, end_event_date, event_ids, latest_published_event_ids)
    else
      info = self.get_model_class(model).where(:updated_at => start_event_date..end_event_date).where(:event_id => event_ids) rescue []
    end
    info.map{|x| x.send(column_name) == "group" }.include? true
  end

  def self.get_deleted_records_for_data_visibility(mobile__app_id, current_user, deleted_data = [])
    arr = ["Agenda","Poll","EKit","Speaker","Quiz","FeedbackForm"] #EvenFeature
    info = []
    event = current_user.event rescue ''
    if event.present?
      arr.each do |a|
        if a == "FeedbackForm"
          data = event.feedback_forms 
          data = data - SyncMobileDataV4.get_feaure_data(data, current_user, "show_feedback_feature")
        elsif a == "EKit"
          data = event.e_kits 
          data = data - SyncMobileDataV4.get_feaure_data(data, current_user, "show_e_kit_feature")
        else
          data = event.send(a.downcase.pluralize) 
          data = data - SyncMobileDataV4.get_feaure_data(data, current_user, get_visiblity_column_name(a))
        end
        data.each do |d|
          info << {:resourse_type => a, :resourse_id => d.id, :updated_at => d.updated_at, :action => "destroy"}
        end
      end
    end
    deleted_data.each do |d|
      info << {:resourse_type => d.resourse_type, :resourse_id => d.resourse_id, :updated_at => d.updated_at, :action => "destroy"}
    end

    return info.flatten
  end

  def self.site_url_custom(custom_page)
    APP_URL + "/events/#{custom_page.event_id}/custom_pages?page_type=#{custom_page.class.table_name}&invitee_id="
  end
end
