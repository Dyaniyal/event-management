class AddMappingStyleAndSizeToBadgePdf < ActiveRecord::Migration
  def change
  	add_column :badge_pdfs, :field1_parameters, :string
  	add_column :badge_pdfs, :field2_parameters, :string
  	add_column :badge_pdfs, :field3_parameters, :string
  	add_column :badge_pdfs, :field4_parameters, :string
  end
end
