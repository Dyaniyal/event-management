class AddStatusToUserRegistrations < ActiveRecord::Migration
  def change
    add_column :user_registrations, :status, :string
  end
end
