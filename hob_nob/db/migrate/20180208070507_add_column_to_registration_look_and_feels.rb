class AddColumnToRegistrationLookAndFeels < ActiveRecord::Migration
  def change
  	add_column :registration_look_and_feels, :footer_color, :string
  end
end
