class RenameFieldLandingPageToMarketingAppInEvents < ActiveRecord::Migration
  def change
  	rename_column :events, :landing_page, :marketing_app
  end
end
