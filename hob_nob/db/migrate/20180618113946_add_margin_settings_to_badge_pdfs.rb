class AddMarginSettingsToBadgePdfs < ActiveRecord::Migration
  def change
	  add_column :badge_pdfs, :top, :integer
	  add_column :badge_pdfs, :left, :integer
	  add_column :badge_pdfs, :color, :string
	  add_column :badge_pdfs, :font_size, :integer
  end
end
