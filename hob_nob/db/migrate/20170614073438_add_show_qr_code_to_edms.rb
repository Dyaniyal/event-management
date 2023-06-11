class AddShowQrCodeToEdms < ActiveRecord::Migration
  def change
    add_column :edms, :show_qr_code, :string
  end
end
