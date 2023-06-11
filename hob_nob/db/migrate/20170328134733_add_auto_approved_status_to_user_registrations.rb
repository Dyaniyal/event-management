class AddAutoApprovedStatusToUserRegistrations < ActiveRecord::Migration
  def change
    add_column :user_registrations, :auto_approved_status, :string
  end
end
