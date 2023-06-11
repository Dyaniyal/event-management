class AddMultLngEventsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :mult_lng_events, :boolean, :default => false
  end
end
