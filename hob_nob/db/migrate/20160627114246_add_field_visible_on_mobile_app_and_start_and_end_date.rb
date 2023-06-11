class AddFieldVisibleOnMobileAppAndStartAndEndDate < ActiveRecord::Migration
  def change
  	add_column :registration_settings, :start_date, :datetime
  	add_column :registration_settings, :end_date, :datetime
  end
end
