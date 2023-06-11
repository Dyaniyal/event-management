class AddColumnsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :description, :text
    add_column :notifications, :push_page, :string
    add_column :notifications, :page_id, :integer
    add_column :notifications, :push_datetime, :datetime
    add_column :notifications, :event_id, :integer
    add_column :notifications, :pushed, :boolean, :default => false
  end
end
