class AddBottomRightToBadgePdfs < ActiveRecord::Migration
  def change
    add_column :badge_pdfs, :bottom, :integer
    add_column :badge_pdfs, :right, :integer
  end
end