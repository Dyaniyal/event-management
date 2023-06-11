class AddAllowQrCodeToBadgePdf < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :allow_qr_code, :string, :default => "no"
  end
end
