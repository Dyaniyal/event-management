class AddTelecallerStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :telecaller_status, :string, :default=>"active"
  end
end
