class AddColumnToMicrositeLookAndFeels < ActiveRecord::Migration
  def change
  	add_column :microsite_look_and_feels, :page_font, :string
  end
end
