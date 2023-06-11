class AuthenticationColumnToInvitee < ActiveRecord::Migration
  def change
  	add_column :invitees, :encrypted_password, :string, limit: 255, default: "", null: false
    add_column :invitees, :salt, :string, limit: 255
    add_column :invitees, :key, :string, limit: 255
    add_column :invitees, :secret_key, :string, limit: 255
    add_column :invitees, :authentication_token, :string, limit: 255
  end
end
