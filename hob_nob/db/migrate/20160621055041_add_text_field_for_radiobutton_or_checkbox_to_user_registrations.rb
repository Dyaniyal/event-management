class AddTextFieldForRadiobuttonOrCheckboxToUserRegistrations < ActiveRecord::Migration
  def change
  	add_column :user_registrations, :text_box_for_checkbox_or_radiobutton, :string
  end
end
