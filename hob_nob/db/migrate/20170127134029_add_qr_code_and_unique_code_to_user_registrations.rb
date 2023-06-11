class AddQrCodeAndUniqueCodeToUserRegistrations < ActiveRecord::Migration
  def change
  	add_column :user_registrations, :unique_confirmation_code, :string
  	add_attachment :user_registrations, :qr_code
  end
end
