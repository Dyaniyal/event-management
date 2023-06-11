class AddActionableIdToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :actionable_id, :string
  end
end
