class ChangeInviteeApplicationStatusColumnName < ActiveRecord::Migration
  def change
  	rename_column :invitees, :application_status, :visible_status
  end
end
