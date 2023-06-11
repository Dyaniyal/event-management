class AddSocialFieldsToMicrosites < ActiveRecord::Migration
  def change
  	add_column :microsites, :twitter_id, :string
    add_column :microsites, :facebook_id, :string
    add_column :microsites, :linkedin_id, :string
    add_column :microsites, :instagram_id, :string
    add_column :microsites, :google_id, :string
  end
end
