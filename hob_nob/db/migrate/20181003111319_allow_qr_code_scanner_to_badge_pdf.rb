class AllowQrCodeScannerToBadgePdf < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :allow_qr_code_scanner, :boolean, default: false
  end
end
