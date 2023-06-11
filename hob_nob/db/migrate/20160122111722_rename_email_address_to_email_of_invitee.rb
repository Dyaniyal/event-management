class RenameEmailAddressToEmailOfInvitee < ActiveRecord::Migration
  def change
  	rename_column :invitees, :email_address, :email
  end
end
