class AddQrCodeRegistrationToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :qr_code_registration, :boolean
  end
end
