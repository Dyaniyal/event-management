class AddIndexOnUpdatedAt < ActiveRecord::Migration
  def change
    add_index :themes, :updated_at
    add_index :events, :updated_at
    add_index :log_changes, :resourse_type
  end
end