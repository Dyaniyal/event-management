class AddQrCodePageColorToBadgePdf < ActiveRecord::Migration
  def change
    add_column :badge_pdfs, :qr_code_page_color, :string
  end
end