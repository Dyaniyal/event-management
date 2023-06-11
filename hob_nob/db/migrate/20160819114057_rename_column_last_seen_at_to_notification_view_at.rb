class RenameColumnLastSeenAtToNotificationViewAt < ActiveRecord::Migration
  def change
    rename_column :invitees, :last_seen_at, :notification_viewed_at
  end
end
