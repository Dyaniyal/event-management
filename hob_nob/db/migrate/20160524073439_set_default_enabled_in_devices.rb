class SetDefaultEnabledInDevices < ActiveRecord::Migration
  def change
  	change_column :devices, :enabled, :string, :default => "true"
  end
end
