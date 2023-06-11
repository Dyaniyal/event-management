class AddEmailFieldToInviteeStructures < ActiveRecord::Migration
  def change
    add_column :invitee_structures, :email_field, :string
  end
end
