class AddRegistrationClosedMsgInLookAndFeel < ActiveRecord::Migration
  def change
  	remove_column :registration_settings, :submit_msg, :text
  	add_column :registration_look_and_feels, :submit_msg, :text
  end
end
