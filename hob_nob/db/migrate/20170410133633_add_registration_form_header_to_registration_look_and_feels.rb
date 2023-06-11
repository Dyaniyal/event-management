class AddRegistrationFormHeaderToRegistrationLookAndFeels < ActiveRecord::Migration
  def change
    add_column :registration_look_and_feels, :registration_form_header, :text
  end
end
