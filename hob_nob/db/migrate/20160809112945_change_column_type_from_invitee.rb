class ChangeColumnTypeFromInvitee < ActiveRecord::Migration
  def up
    change_column :invitees, :facebook_id, :text
    change_column :invitees, :twitter_id, :text
  end

  def down
    change_column :invitees, :facebook_id, :string
    change_column :invitees, :twitter_id, :string
  end
end
