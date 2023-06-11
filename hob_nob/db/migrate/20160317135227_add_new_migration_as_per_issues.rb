class AddNewMigrationAsPerIssues < ActiveRecord::Migration
  def change
  	add_index :agendas, [:start_agenda_time], :name => "index_on_start_agenda_time_in_agendas"

  	add_index :conversations, [:updated_at], :name => "index_on_updated_at_in_conversations"
  	add_index :conversations, [:user_id], :name => "index_on_user_id_in_conversations"

  	add_index :likes, [:likable_type], :name => "index_on_likable_type_in_likes"

  	add_index :comments, [:commentable_type], :name => "index_on_commentable_type_in_comments"

  	add_index :mobile_applications, [:updated_at], :name => "index_on_updated_at_in_mobile_applications"

  	add_index :users, [:authentication_token], :name => "index_on_authentication_token_in_users"

  	add_index :themes, [:admin_theme], :name => "index_on_admin_theme_in_themes"
  	add_index :themes, [:preview_theme], :name => "index_on_preview_theme_in_themes"

  	add_index :event_features, [:sequence], :name => "index_on_sequence_in_event_features"
  	add_index :event_features, [:name], :name => "index_on_name_in_event_features"

  	add_index :faqs, [:sequence], :name => "index_on_sequence_in_faqs"
  	
  	add_index :invitees, [:authentication_token], :name => "index_on_authentication_token_in_invitees"
  	add_index :invitees, [:visible_status], :name => "index_on_visible_status_in_invitees"
  	add_index :invitees, [:email], :name => "index_on_email_in_invitees"
  	add_index :invitees, [:company_name], :name => "index_on_company_name_in_invitees"

  	add_index :ratings, [:rated_by], :name => "index_on_rated_by_in_ratings"
  	add_index :ratings, [:ratable_id], :name => "index_on_ratable_id_in_ratings"
  	add_index :ratings, [:ratable_type], :name => "index_on_ratable_type_in_ratings"

  	add_index :images, [:imageable_type], :name => "index_on_imageable_type_in_images"

  	add_index :log_changes, [:updated_at], :name => "index_on_updated_at_in_log_changes"

  	add_index :notifications, [:updated_at], :name => "index_on_updated_at_in_notifications"

  end
end
