class AddQrCodeRegistrationTimeToInvitees < ActiveRecord::Migration
  def change
    add_column :invitees, :qr_code_registration_time, :datetime
  end
end
