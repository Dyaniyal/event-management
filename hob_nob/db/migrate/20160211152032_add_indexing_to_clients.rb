class AddIndexingToClients < ActiveRecord::Migration
  def change
  	add_index :clients, [:name], :name => "index_name_on_clients"
  	#add_index :clients, [:updated_at], :name => "index_updated_at_on_clients"
  	add_index :clients, [:status], :name => "index_status_on_clients"
  end
end
