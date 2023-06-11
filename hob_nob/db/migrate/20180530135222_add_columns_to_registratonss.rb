class AddColumnsToRegistratonss < ActiveRecord::Migration
  def change
  	add_column :registration_look_and_feels, :header_font_size, :string
  	add_column :registration_look_and_feels, :page_font_style, :string
  end
end
