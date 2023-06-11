class AddIndexToInviteeDataForUniqueness < ActiveRecord::Migration
  def change 
    add_index :invitee_data, [:attr1, :invitee_structure_id], unique: true
  end
end
