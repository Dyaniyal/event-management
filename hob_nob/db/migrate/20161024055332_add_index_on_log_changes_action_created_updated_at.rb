class AddIndexOnLogChangesActionCreatedUpdatedAt < ActiveRecord::Migration
  def change
    add_index :log_changes, [:action, :created_at, :updated_at]
  end
end
