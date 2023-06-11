class AddCountColumnsToBadgePdfs < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :unique_field1, :string
  	add_column :badge_pdfs, :unique_field2, :string
  	add_column :badge_pdfs, :unique_field3, :string

  	add_column :badge_pdfs, :value_wise_field1, :string
  	add_column :badge_pdfs, :value_wise_field2, :string
  	add_column :badge_pdfs, :value_wise_field3, :string
  	add_column :badge_pdfs, :value_wise_field4, :string
  	add_column :badge_pdfs, :value_wise_field5, :string
  	add_column :badge_pdfs, :value_wise_field6, :string
  	add_column :badge_pdfs, :value_wise_field7, :string
  	add_column :badge_pdfs, :value_wise_field8, :string
  	add_column :badge_pdfs, :value_wise_field9, :string  	
  end
end
