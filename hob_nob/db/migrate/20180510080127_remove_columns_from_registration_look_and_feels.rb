class RemoveColumnsFromRegistrationLookAndFeels < ActiveRecord::Migration
  def change
  	remove_column :registration_look_and_feels, :header_font_size, :string
  	remove_column :registration_look_and_feels, :page_font_style, :string
  end
end
