class AddColumnsToMicrositeLookAndFeels < ActiveRecord::Migration
  def change
  	add_column :microsite_look_and_feels, :microsite_form_header, :text
  	add_column :microsite_look_and_feels, :button_font_color, :string
  	add_column :microsite_look_and_feels, :button_text, :string
  end
end
