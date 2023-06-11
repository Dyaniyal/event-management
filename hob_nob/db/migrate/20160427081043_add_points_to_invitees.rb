class AddPointsToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :points, :integer
  end
end
