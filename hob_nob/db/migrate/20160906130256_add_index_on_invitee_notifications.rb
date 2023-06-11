class AddIndexOnInviteeNotifications < ActiveRecord::Migration
  def change
  add_index :invitee_notifications, [:notification_id, :invitee_id]

  end
end
