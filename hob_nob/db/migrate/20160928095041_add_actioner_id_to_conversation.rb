class AddActionerIdToConversation < ActiveRecord::Migration
  def change
    add_column :conversations, :actioner_id, :integer
  end
end
