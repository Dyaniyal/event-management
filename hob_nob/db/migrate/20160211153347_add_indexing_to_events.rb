class AddIndexingToEvents < ActiveRecord::Migration
  def change
  	add_index :events, [:event_name], :name => "index_event_name_on_events"
  	add_index :events, [:start_event_date], :name => "index_start_event_date_on_events"
  	add_index :events, [:end_event_date], :name => "index_end_event_date_on_events"
  	add_index :events, [:start_event_time], :name => "index_start_event_time_on_events"
  	add_index :events, [:end_event_time], :name => "index_end_event_time_on_events"
  	add_index :events, [:status], :name => "index_status_on_events"
  	#add_index :events, [:updated_at], :name => "index_updated_at_on_events"
  	add_index :events, [:event_code], :name => "index_event_code_on_events"
  end
end
