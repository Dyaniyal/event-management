class AddBadgeCountToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :badge_count, :integer
  end
end
