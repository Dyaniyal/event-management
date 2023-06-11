class AddAssignGroupingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :assign_grouping, :string
  end
end
