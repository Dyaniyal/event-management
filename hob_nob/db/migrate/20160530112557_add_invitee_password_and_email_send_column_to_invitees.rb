class AddInviteePasswordAndEmailSendColumnToInvitees < ActiveRecord::Migration
  def change
  	add_column :invitees, :invitee_password, :string
  	add_column :invitees, :email_send, :string, :default => "false"
  end
end
