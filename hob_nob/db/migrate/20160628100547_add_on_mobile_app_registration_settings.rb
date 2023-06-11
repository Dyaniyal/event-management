class AddOnMobileAppRegistrationSettings < ActiveRecord::Migration
  def change
  	add_column :registration_settings, :on_mobile_app, :string
  end
end
