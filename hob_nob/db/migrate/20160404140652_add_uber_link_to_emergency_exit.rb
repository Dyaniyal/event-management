class AddUberLinkToEmergencyExit < ActiveRecord::Migration
  def change
    add_column :emergency_exits, :uber_link, :string
  end
end
