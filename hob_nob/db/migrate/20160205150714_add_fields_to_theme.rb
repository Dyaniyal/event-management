class AddFieldsToTheme < ActiveRecord::Migration
  def change
  	add_column :themes, :header_color, :string
  	add_column :themes, :footer_color, :string
  end
end
