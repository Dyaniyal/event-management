class AddInviteeProfilePicToQnas < ActiveRecord::Migration
  def change
    add_column :qnas, :invitee_profile_pic, :string
  end
end
