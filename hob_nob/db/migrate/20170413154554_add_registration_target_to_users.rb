class AddRegistrationTargetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :registration_target, :integer
  end
end
