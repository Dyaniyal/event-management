class AddQrCodeToInvitees < ActiveRecord::Migration
  def change
	add_column :invitees, :mobile_no, :string
	add_column :invitees, :website, :string
	add_column :invitees, :street, :string
	add_column :invitees, :locality, :string
	add_column :invitees, :location, :string
	add_column :invitees, :country, :string
	add_column :invitees, :qr_code_file_name, :string
	add_column :invitees, :qr_code_content_type, :string
	add_column :invitees, :qr_code_file_size, :integer
	add_column :invitees, :qr_code_updated_at, :datetime
  end
end
