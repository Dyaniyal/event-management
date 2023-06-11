class AddEventTimezoneToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :event_timezone, :string
  end
end
