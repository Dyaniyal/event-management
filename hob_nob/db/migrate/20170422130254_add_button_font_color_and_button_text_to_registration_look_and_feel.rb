class AddButtonFontColorAndButtonTextToRegistrationLookAndFeel < ActiveRecord::Migration
  def change
  	add_column :registration_look_and_feels, :button_font_color, :string
  	add_column :registration_look_and_feels, :button_text, :string
  end
end
