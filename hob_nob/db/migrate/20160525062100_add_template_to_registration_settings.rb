class AddTemplateToRegistrationSettings < ActiveRecord::Migration
  def change
  	add_column :registration_settings, :template, :string
  end
end
