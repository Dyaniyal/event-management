class AddDesignationToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :designation, :string
  end
end
