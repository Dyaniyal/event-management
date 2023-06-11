class AddFieldsToBadgePdfs < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :reg_match_name_field, :string
  	add_column :badge_pdfs, :reg_match_designation_field, :string
  	add_column :badge_pdfs, :reg_match_company_field, :string
  	add_column :badge_pdfs, :reg_match_email_field, :string
  end
end
