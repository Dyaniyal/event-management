class AddSocialLinks < ActiveRecord::Migration
  def change
  	add_column :edms, :facebook_link, :string
  	add_column :edms, :google_plus_link, :string
  	add_column :edms, :linkedin_link, :string
  	add_column :edms, :twitter_link, :string
  	add_column :edms, :header_color, :string
  	add_column :edms, :footer_color, :string
  	add_column :edms, :sender_email, :string
  end
end
