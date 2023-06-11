class AddReadcolumnsToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :open, :string, :default => "false"
  	add_column :notifications, :unread, :string, :default => "true"
  end
end
