class AddColumnToBadgePdfs < ActiveRecord::Migration
  def change
    add_column :badge_pdfs, :skip_print, :boolean, :default => false
  end
end
