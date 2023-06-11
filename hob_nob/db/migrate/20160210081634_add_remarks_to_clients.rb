class AddRemarksToClients < ActiveRecord::Migration
  def change
    add_column :clients, :remarks, :string
  end
end
