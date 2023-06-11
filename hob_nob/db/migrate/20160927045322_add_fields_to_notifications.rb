class AddFieldsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :push, :boolean 
    add_column :notifications, :show_on_notification_screen, :boolean
    add_column :notifications, :show_on_activity, :boolean
    add_attachment :notifications, :image_for_show_notification
  end
end
