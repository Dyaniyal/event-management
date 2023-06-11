class AddAllEventsListingScreenToMobileApplications < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :all_events_listing, :string, :default => "yes"
  end
end
