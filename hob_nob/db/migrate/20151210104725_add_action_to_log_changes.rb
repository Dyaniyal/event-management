class AddActionToLogChanges < ActiveRecord::Migration
  def change
    add_column :log_changes, :action, :string
  end
end
