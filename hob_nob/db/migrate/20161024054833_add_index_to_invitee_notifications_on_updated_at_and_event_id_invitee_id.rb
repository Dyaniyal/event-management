class AddIndexToInviteeNotificationsOnUpdatedAtAndEventIdInviteeId < ActiveRecord::Migration
  def change
    add_index :invitee_notifications, [:updated_at, :event_id, :invitee_id], :name => "index_invitee_noti_updated_at_event_id_invitee_id"
  end
end
