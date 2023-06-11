class AddTelecallerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :telecaller, :string
  end
end
