class AddBadgeWidthBadgeHeightToBadgePdf < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :badge_height, :string
  	add_column :badge_pdfs, :badge_width, :string
  end
end
