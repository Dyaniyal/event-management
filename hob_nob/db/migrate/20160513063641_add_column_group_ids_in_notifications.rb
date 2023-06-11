class AddColumnGroupIdsInNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :group_ids, :text
  end
end
