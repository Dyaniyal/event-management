class AddColumnSubmitMsgToRegistrationSettings < ActiveRecord::Migration
  def change
    add_column :registration_settings, :submit_msg, :text
  end
end
