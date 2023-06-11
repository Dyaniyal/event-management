class AddScanBgImageToBatchpdfs < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :scan_bg_image_file_name, :string
  	add_column :badge_pdfs, :scan_bg_image_content_type, :string
  	add_column :badge_pdfs, :scan_bg_image_file_size, :integer
  	add_column :badge_pdfs, :scan_bg_image_updated_at, :datetime
  end
end
