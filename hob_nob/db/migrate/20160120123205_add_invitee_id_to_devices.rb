class AddInviteeIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :invitee_id, :integer
  end
end
