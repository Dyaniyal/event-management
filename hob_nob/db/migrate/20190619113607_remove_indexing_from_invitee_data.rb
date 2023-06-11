class RemoveIndexingFromInviteeData < ActiveRecord::Migration
  def change
  	remove_index :invitee_data, column: [:attr1, :invitee_structure_id]
  end
end
