class AddIndexingToEventsApis < ActiveRecord::Migration
  def change
  	add_index :images, :updated_at, :name => "index_images_on_events_index"
  	add_index :winners, :updated_at, :name => "index_winners_on_events_index"
  	add_index :comments, [:commentable_id, :commentable_type, :updated_at], :name => "index_comments_on_events_index"
  	add_index :notifications, [:pushed, :event_id], :name => "index_notifications_on_events_index"
  	add_index :favorites, [:invitee_id, :updated_at], :name => "index_favorites_on_events_index"
  	add_index :log_changes, [:created_at, :action], :name => "index_log_changes_on_events_index"
  	add_index :likes, [:likable_id, :likable_type, :updated_at], :name => "index_likes_on_events"
  	add_index :user_polls, [:poll_id, :updated_at], :name => "index_user_polls_on_events_index"
  	add_index :user_quizzes, [:quiz_id, :updated_at], :name => "index_user_quizzes_on_events_index"
  	add_index :agendas, :event_id, :name => "index_agendas_on_events_index"
  	add_index :ratings, [:ratable_id, :updated_at], :name => "index_ratings_on_events_index"
  	add_index :user_feedbacks, [:feedback_id, :updated_at], :name => "index_user_feedbacks_on_events_index"
  	add_index :e_kits, :updated_at, :name => "index_e_kits_on_events_index"
  	add_index :analytics, :points, :name => "index_analytics_on_events_index"
  	add_index :invitees, [:event_id, :visible_status], :name => "index_invitees_on_events_index"
  	add_index :invitees, [:event_id, :email], :name => "index_invitees_on_events_index_api"
  	add_index :invitees, :updated_at, :name => "index_inviteees_on_events_index"
  	add_index :invitee_notifications, [:notification_id, :invitee_id], :name => "index_invitee_notifications_on_events_index"
  	add_index :user_feedbacks, [:feedback_id, :user_id], :name => "index_user_feedbacks_on_events_index_api"
  end
end
