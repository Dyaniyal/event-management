class AddMobileDetailToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :device_token, :string
  	add_column :users, :key, :string
  	add_column :users, :secret_key, :string
  	add_column :users, :device_type, :string
  	add_column :users, :authentication_token, :string
  end
end
