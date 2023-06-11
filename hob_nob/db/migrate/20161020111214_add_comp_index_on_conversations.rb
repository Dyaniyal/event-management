class AddCompIndexOnConversations < ActiveRecord::Migration
  def change
    add_index :conversations, [:updated_at, :event_id]
  end
end
