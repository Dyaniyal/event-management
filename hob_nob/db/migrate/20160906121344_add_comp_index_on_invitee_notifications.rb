class AddCompIndexOnInviteeNotifications < ActiveRecord::Migration
  def change
    add_index :invitee_notifications, [:event_id, :invitee_id]
  end
end
