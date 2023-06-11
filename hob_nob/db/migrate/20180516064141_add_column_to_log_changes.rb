class AddColumnToLogChanges < ActiveRecord::Migration
  def change
  	add_column :log_changes, :email , :string
  	add_column :log_changes, :user_email, :string
  	add_column :log_changes, :event_id, :integer
  	add_column :log_changes, :client_id, :integer
  	add_column :log_changes, :licensee_id, :integer
  end
end
