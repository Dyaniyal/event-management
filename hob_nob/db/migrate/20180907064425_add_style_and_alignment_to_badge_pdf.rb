class AddStyleAndAlignmentToBadgePdf < ActiveRecord::Migration
  def change
	add_column :badge_pdfs, :print_alignment, :string
	add_column :badge_pdfs, :printing_font_style, :string
	add_column :badge_pdfs, :qr_code_attr, :string
  end
end
