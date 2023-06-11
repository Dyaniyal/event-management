class AddExpiryDateColumnToInviteeStructures < ActiveRecord::Migration
  def change
  	add_column :invitee_structures, :expiry_date, :datetime
  end
end
