class AddIndexingToTables < ActiveRecord::Migration
  def change
  	add_index :abouts, [:event_id], :name => "index_abouts_on_event_id"
    
    add_index :agendas_dayoptions, [:agenda_id], :name => "index_agendas_dayoptions_on_agenda_id"
    
    add_index :awards, [:event_id], :name => "index_awards_on_event_id"
    
    add_index :cities, [:event_id], :name => "index_cities_on_event_id"
    
    add_index :clients, [:licensee_id], :name => "index_clients_on_licensee_id"
    
    add_index :clients_users, [:client_id], :name => "index_clients_users_on_client_id"
    add_index :clients_users, [:user_id], :name => "index_clients_users_on_user_id"
    
    add_index :comments, [:user_id], :name => "index_comments_on_user_id"
    
    add_index :contacts, [:event_id], :name => "index_contacts_on_event_id"
    
    add_index :conversations, [:event_id], :name => "index_conversations_on_event_id"
    
    add_index :devices, [:user_id], :name => "index_devices_on_user_id"
    add_index :devices, [:invitee_id], :name => "index_devices_on_invitee_id"
    add_index :devices, [:client_id], :name => "index_awards_on_client_id"
    
    add_index :e_kits, [:event_id], :name => "index_e_kits_on_event_id"
    
    add_index :emergency_exits, [:event_id], :name => "index_emergency_exits_on_event_id"
    
    add_index :event_features, [:event_id], :name => "index_event_features_on_event_id"
    
    add_index :event_groups, [:client_id], :name => "index_event_groups_on_client_id"
    
    add_index :events, [:client_id], :name => "index_events_on_client_id"
    add_index :events, [:city_id], :name => "index_events_on_city_id"
    add_index :events, [:theme_id], :name => "index_events_on_theme_id"
    add_index :events, [:mobile_application_id], :name => "index_events_on_mobile_application_id"
    
    add_index :events_mobile_applications, [:event_id], :name => "index_events_mobile_applications_on_event_id"
    
    add_index :faqs, [:event_id], :name => "index_faqs_on_event_id"
    add_index :faqs, [:user_id], :name => "index_faqs_on_user_id"
    
    add_index :feedbacks, [:event_id], :name => "index_feedbacks_on_event_id"
    
    add_index :highlight_images, [:event_id], :name => "index_highlight_images_on_event_id"
    
    add_index :imports, [:importable_id], :name => "index_imports_on_importable_id"
    
    add_index :likes, [:likable_id], :name => "index_likes_on_likable_id"
    add_index :likes, [:user_id], :name => "index_likes_on_user_id"
    
    add_index :log_changes, [:user_id], :name => "index_log_changes_on_user_id"
    add_index :log_changes, [:resourse_id], :name => "index_faqs_on_resourse_id"
    
    add_index :mobile_applications, [:client_id], :name => "index_mobile_applications_on_client_id"
    
    add_index :notes, [:event_id], :name => "index_notes_on_event_id"
    
    add_index :notifications, [:resourceable_id], :name => "index_notifications_on_resourceable_id"
    add_index :notifications, [:page_id], :name => "index_notifications_on_page_id"
    add_index :notifications, [:event_id], :name => "index_faqs_on_event_id"
    
    add_index :panels, [:event_id], :name => "index_panels_on_event_id"
    add_index :panels, [:panel_id], :name => "index_panels_on_panel_id"
    
    add_index :qnas, [:event_id], :name => "index_qnas_on_event_id"
    
    add_index :sponsors, [:event_id], :name => "index_sponsors_on_event_id"
    
    add_index :themes, [:licensee_id], :name => "index_themes_on_licensee_id"
    
    add_index :user_feedbacks, [:feedback_id], :name => "index_user_feedbacks_on_feedback_id"
    add_index :user_feedbacks, [:user_id], :name => "index_user_feedbacks_on_user_id"
    
    add_index :winners, [:award_id], :name => "index_winners_on_award_id"
  end
end
