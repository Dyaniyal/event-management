class AddEventListingDisplayUpdatedAtToMobileApplications < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :event_listing_display_updated_at, :datetime
  end
end
