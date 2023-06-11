class AddClientCodeToClients < ActiveRecord::Migration
  def change
    add_column :clients, :client_code, :string
  end
end
