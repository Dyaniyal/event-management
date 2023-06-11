class IndexingOnMobilappliRatingLogchangeNotifiModels < ActiveRecord::Migration
  def change
  	add_index :mobile_applications, [:application_type], :name => "index_on_application_type_in_mobile_applications"

  	add_index :ratings, [:updated_at], :name => "index_on_updated_at_in_ratings"
  	
  	add_index :log_changes, [:created_at], :name => "index_on_created_at_in_log_changes"
  	
  	add_index :notifications, [:pushed], :name => "index_on_pushed_in_notifications"
  	add_index :notifications, [:push_datetime], :name => "index_on_push_datetime_in_notifications"
  end
end
