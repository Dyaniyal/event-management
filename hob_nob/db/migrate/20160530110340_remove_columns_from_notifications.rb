class RemoveColumnsFromNotifications < ActiveRecord::Migration
  def change
  	remove_column :notifications, :receiver_id
  	remove_column :notifications, :resourceable_id
  	remove_column :notifications, :resourceable_type
  	remove_column :notifications, :open
  	remove_column :notifications, :unread
  	remove_column :notifications, :status
  	remove_column :notifications, :name
  end
end