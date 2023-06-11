class AddEventTimezoneToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :event_timezone, :string
  end
end
