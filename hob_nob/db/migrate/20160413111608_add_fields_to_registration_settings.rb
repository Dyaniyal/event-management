class AddFieldsToRegistrationSettings < ActiveRecord::Migration
  def change
    add_column :registration_settings, :registration, :string
    add_column :registration_settings, :login, :string
    add_column :registration_settings, :response_type, :string
  end
end
