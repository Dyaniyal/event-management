class AddIndexingToUsers < ActiveRecord::Migration
  def change
  	add_index :users, [:licensee_id], :name => "index_licensee_id_on_users"
  	add_index :users, [:status], :name => "index_status_on_users"
  	add_index :users, [:client_id], :name => "index_client_id_on_users"
  	#add_index :users, [:updated_at], :name => "index_username_on_users"
  end
end
