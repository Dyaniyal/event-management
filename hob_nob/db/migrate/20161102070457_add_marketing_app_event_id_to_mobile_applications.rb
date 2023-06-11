class AddMarketingAppEventIdToMobileApplications < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :marketing_app_event_id, :string
  end
end
