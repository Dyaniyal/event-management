class AddLastInteractionToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :last_interation, :datetime
  end
end
