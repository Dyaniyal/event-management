class RemoveEventIdFromThemes < ActiveRecord::Migration
  def change
  	remove_column :themes, :event_id
  end
end
