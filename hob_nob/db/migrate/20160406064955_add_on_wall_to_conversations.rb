class AddOnWallToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :on_wall, :string
  end
end
