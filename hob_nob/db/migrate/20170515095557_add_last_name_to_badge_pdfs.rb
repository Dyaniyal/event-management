class AddLastNameToBadgePdfs < ActiveRecord::Migration
  def change
    add_column :badge_pdfs, :last_name, :string
    add_column :badge_pdfs, :last_name_match_field, :string
  end
end
