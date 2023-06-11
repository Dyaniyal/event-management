class AddPreviousStatusToUserRegistrations < ActiveRecord::Migration
  def change
    add_column :user_registrations, :previous_status, :string
  end
end
