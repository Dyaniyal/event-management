class AddLicenseeIdToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :licensee_id, :integer
  	add_column :users, :licensee_status, :string
  end
end
