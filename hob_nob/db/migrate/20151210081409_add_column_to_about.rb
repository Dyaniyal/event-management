class AddColumnToAbout < ActiveRecord::Migration
  def change
  	add_column :abouts, :address, :text
  end
end
