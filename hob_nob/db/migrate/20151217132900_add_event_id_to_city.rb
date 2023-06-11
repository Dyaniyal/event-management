class AddEventIdToCity < ActiveRecord::Migration
  def change
  	add_column :cities, :event_id, :integer
  end
end
