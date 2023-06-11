class AddEventIdToConversationWalls < ActiveRecord::Migration
  def change
    add_column :conversation_walls, :event_id, :integer
  end
end
