class AddLicenseeIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :licensee_id, :integer
  end
end
