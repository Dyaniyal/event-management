class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :package_type, :string
    add_column :users, :licensee_start_date, :datetime
    add_column :users, :licensee_end_date, :datetime
  end
end
