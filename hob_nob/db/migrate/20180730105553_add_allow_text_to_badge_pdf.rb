class AddAllowTextToBadgePdf < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :allow_text, :string, default: "no"
  end
end
