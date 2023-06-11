class AddEmailAndClientIdToDevice < ActiveRecord::Migration
  def change
  	add_column :devices, :email, :string, references: :invitees
  	add_column :devices, :client_id, :integer
  end
end
