class AddUniqIdentifierToInviteeStructures < ActiveRecord::Migration
  def change
    add_column :invitee_structures, :uniq_identifier, :string
  end
end
