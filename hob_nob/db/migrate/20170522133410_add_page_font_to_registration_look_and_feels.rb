class AddPageFontToRegistrationLookAndFeels < ActiveRecord::Migration
  def change
  	add_column :registration_look_and_feels, :page_font, :string
  end
end
