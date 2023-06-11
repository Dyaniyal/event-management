class AddEventIdToTheme < ActiveRecord::Migration
  def change
  	add_column :themes, :event_id, :integer
  end
end
