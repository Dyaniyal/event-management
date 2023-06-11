class AddLoginAtToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :login_at, :string
  end
end
