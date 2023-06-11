class AddLastSeenAtToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :last_seen_at, :datetime
  end
end
