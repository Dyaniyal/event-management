class AddColumnsInUserRegistraionForQrcode < ActiveRecord::Migration
  def change
  	add_column :user_registrations, :qr_code_registration, :boolean, :default => false
  	add_column :user_registrations, :qr_code_registration_time, :datetime
  end
end
