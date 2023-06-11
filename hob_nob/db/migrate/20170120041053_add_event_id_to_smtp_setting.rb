class AddEventIdToSmtpSetting < ActiveRecord::Migration
  def change
  	add_column :smtp_settings, :event_id, :integer  
  end
end
