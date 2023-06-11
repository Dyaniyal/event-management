class AddActivateMobileAppAndActivateEmsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activate_mobile_app, :string
    add_column :users, :activate_ems, :string
  end
end
