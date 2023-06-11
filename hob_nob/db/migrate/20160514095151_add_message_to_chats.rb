class AddMessageToChats < ActiveRecord::Migration
  def change
    add_column :chats, :message, :string
  end
end
