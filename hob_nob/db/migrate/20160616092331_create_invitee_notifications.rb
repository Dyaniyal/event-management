class CreateInviteeNotifications < ActiveRecord::Migration
  def change
    create_table :invitee_notifications do |t|
      t.integer  "event_id"
      t.integer   "invitee_id"
      t.integer   "notification_id"
      t.string   "open", default: "false"
      t.string   "unread", default: "true"

      t.timestamps null: false
    end
  end
end
