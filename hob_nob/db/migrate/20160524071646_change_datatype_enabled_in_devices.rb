class ChangeDatatypeEnabledInDevices < ActiveRecord::Migration
  def change
  	change_column :devices, :enabled, :string
  	
  end
end
