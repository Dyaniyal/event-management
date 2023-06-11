class AddFieldsToEdms < ActiveRecord::Migration
  def change
    add_column :edms, :group_type, :string
    add_column :edms, :group_id, :string
    add_column :edms, :database_email_field, :string
  end
end
