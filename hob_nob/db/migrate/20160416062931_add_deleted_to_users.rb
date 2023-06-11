class AddDeletedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :deleted, :string, default: "false"
  end
end
