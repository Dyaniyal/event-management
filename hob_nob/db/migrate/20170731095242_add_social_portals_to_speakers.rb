class AddSocialPortalsToSpeakers < ActiveRecord::Migration
  def change
  	add_column :speakers, :twitter_id, :string
    add_column :speakers, :facebook_id, :string
    add_column :speakers, :linkedin_id, :string
  end
end
