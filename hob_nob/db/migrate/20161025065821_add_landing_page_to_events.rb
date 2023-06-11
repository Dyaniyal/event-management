class AddLandingPageToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :landing_page, :boolean
  end
end
