class AddUnreadToChats < ActiveRecord::Migration
  def change
    add_column :chats, :unread, :boolean, :default => true
  end
end
