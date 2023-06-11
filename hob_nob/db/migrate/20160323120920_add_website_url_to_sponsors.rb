class AddWebsiteUrlToSponsors < ActiveRecord::Migration
  def change
    add_column :sponsors, :website_url, :text
  end
end
