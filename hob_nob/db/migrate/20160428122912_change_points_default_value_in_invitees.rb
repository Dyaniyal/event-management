class ChangePointsDefaultValueInInvitees < ActiveRecord::Migration
  def change
    change_column_default :invitees, :points, 0
  end
end
