class AddBarColourToTheme < ActiveRecord::Migration
  def change
  	add_column :themes, :bar_color, :string
  	add_attachment :events, :inside_logo
  end
end
