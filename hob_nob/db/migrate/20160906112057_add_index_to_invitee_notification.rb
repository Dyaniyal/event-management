class AddIndexToInviteeNotification < ActiveRecord::Migration
  def change
   add_index :invitee_notifications, :notification_id
  end
end
