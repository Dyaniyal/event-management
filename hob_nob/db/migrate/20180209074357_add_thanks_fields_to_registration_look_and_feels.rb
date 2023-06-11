class AddThanksFieldsToRegistrationLookAndFeels < ActiveRecord::Migration
  def change
  	add_column :registration_look_and_feels, :thank_text, :text
  	add_column :registration_look_and_feels, :footer_require, :string
  end
end
