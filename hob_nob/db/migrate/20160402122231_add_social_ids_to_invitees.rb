class AddSocialIdsToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :twitter_id, :string
    add_column :invitees, :facebook_id, :string
  end
end
