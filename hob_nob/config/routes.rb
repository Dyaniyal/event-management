Rails.application.routes.draw do

  match "/404", :to => "errors#not_found", :via => :all
  
  match "/500", :to => "errors#internal_server_error", :via => :all


  
mount Ckeditor::Engine => '/ckeditor'
devise_for :users
as :user do
  get 'passwords/change_password' => 'devise/passwords#edit'
  put 'passwords' => 'devise/passwords#update'
end
#root "admin/dashboards#index"
root "admin/homes#index"
get 'back' => 'application#back'

resources :custom_pages

resources :events, :controller => "microsites", :as => "microsites"
resources :events do
  resources :custom_pages
end

namespace :admin do
  get 'bee_editor' => 'bee_editors#index'
  get '/mobile_applications/:mobile_application_id/success' => 'external_login#show'
  get '/events/:event_id/success' => 'user_registrations#show'
  get '/unsubscribes/success' => 'unsubscribes#show'
  get '/unsubscribes' => 'unsubscribes#index'
  get 'bee_editor/token' => 'bee_editors#token'
  get 'bee_editor/template' => 'bee_editors#template'
    
  # get '/check_email_existance' => 'users#check_email_existance'
  resources :time_zones, :notification_action_changes
  resources :dashboards, :themes, :manage_users, :users, :roles, :homes, :smtp_settings, :log_changes
  resources :profiles, :manage_mobile_apps, :downloads, :external_login, :prohibited_accesses, :change_roles, :icon_libraries
  resources :licensees do
    resources :clients    
  end
  resources :clients do
    resources :users, :marketing_apps
    resources :mobile_applications do
      resources :push_pem_files
    end
    resources :event_groups
    resources :events
    resources :fonts, except: [:show, :edit, :update]
  end
  resources :mobile_applications do
    resources :external_login
  end

  resources :events do
    resources :microsites do
      resources :microsite_look_and_feels, :microsite_features, :microsite_menus, :microsite_sequences
    end
  end

  resources :events do
    resources :abouts, :event_highlights, :emergency_exits, :themes, :sequences,:leaderboards, :chats, :invitee_groups, :qr_code_scanners, :qr_code_texts, :warehouse_timers,:qna_walls,:conversation_walls,:poll_walls,:quiz_walls, :activity_feeds, :feedback_forms, :export_qr_codes, :badge_pdfs, :microsites
    resources :speakers, :attendees, :invitees, :agendas, :conversations, :users, :notifications
    resources :event_features, :menus, :faqs, :images, :highlight_images, :feedbacks, :sponsors, :qnas, :feedbacks
    resources :e_kits, :contacts, :panels, :imports, :user_registrations
    resources :groupings, :exhibitors, :manage_feature_status, :analytics, :registration_settings, :custom_page1s, :custom_page2s, :custom_page3s, :custom_page4s, :custom_page5s, :invitee_datas,:my_travels,:manage_invitee_fields,:qna_settings, :qnas, :user_qnas, :feedbacks,:registration_look_and_feels,:registration_details,:auto_status_emails,:telecaller_accessible_columns,:telecaller_dashboards,:telecaller_groups,:campaign_details,:track_links ,:venue_sections,:invitee_accesses,:invitee_searches, :qr_scanner_details,:registration_statistics,:onsite_registrations,:maps, :folders, :consent_questions, :onsite_accessible_columns
    resources :custom_page6s, :custom_page7s, :custom_page8s, :custom_page9s, :custom_page10s, :telecaller_searchs
    resources :telecaller_invitees, :import_data_api
    resources :multi_lng_events, :unsubscribes, :log_changes
    # resources :feedback_forms do
    #   resources :feedbacks
    # end
    resources :feedback_forms,:feedbacks
    
    resources :telecallers do
      collection do
        get :attended_records
      end
    end

    resources :polls do
      resources :user_polls
    end

    resources :quizzes do
      resources :user_quizzes
    end

    # resources :invitee_datas do
    #   collection do
    #     post 'update_details'
    #   end
    # end

    resources :user_polls, :user_quizzes, :user_feedbacks, :likes, :comments

    resources :mobile_applications do
      resources :store_infos
      resources :mobile_consent_questions, :consent_question_look_and_feels
    end  
    resources :awards do
      resources :winners 
    end
    resources :invitee_structures do
      resources :invitee_datas
    end
    resources :registrations
    get '/user_qnas/new/:rid/:sid' => 'user_qnas#new', :as => "receiver_qnas"
    resources :campaigns do
      resources :edms do
        put :toggle_tele_assigned, on: :member
      end
    end
    resources :track_link_users
  end

  # resources :imports
end
# resources :events do
#   resources :microsites 
# end

get "/api/v1/activity_feeds?event_id=:event_id&social=true" => redirect("/api/v1/events/:event_id/social_feeds")
  namespace :api do
    namespace :v1 do
      get 'tokens/destroy_token' => 'tokens#destroy_token', defaults: {format: 'json'}
      post 'tokens/get_key' => 'tokens#get_key'#, defaults: {format: 'json'}
      get 'tokens/check_token' => 'tokens#check_token', defaults: {format: 'json'}
      post 'tokens/user_sign_up' => 'tokens#user_sign_up', defaults: {format: 'json'}
      post 'tokens/facebook_authentication' => 'tokens#facebook_authentication', defaults: {format: 'json'}
      post 'tokens/twitter_authentication' => 'tokens#twitter_authentication', defaults: {format: 'json'}
      resources :events do 
        post 'delete_mobile_data', on: :collection 
        resources :chats do 
          post 'update_chat_read_status', on: :collection # method used for update msg read status for api.
        end
        resources :invitee_chats,:social_feeds  
      end
      resources :tokens, :social_media_authentications, :abouts, :agendas, :speakers, :invitees, :leaderboards, :attendees, :images, :ratings, defaults: {format: 'json'} 
      resources :faqs, :notifications, :conversations, :comments, :qnas, :polls,:invitee_trackings, defaults: {format: 'json'}
      resources :awards, :event_features, :sponsors, :likes, :notes, :user_feedbacks,:e_kits, :mobile_applications, :passwords, :my_travels, defaults: {format: 'json'}
      resources :activity_feeds,:visitor_registrations, :mobile_consent_question_answers
    end
    namespace :v2 do
      resources :events
    end
    namespace :v3 do
      resources :events
    end
    namespace :v4 do
      resources :events
      resources :e_kits
    end
    namespace :v5 do
      resources :events, :conversations, :images, :leaderboards, :invitees
    end
  end
end