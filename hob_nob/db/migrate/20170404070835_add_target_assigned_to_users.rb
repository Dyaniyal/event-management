class AddTargetAssignedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :target_assigned, :integer
  end
end
