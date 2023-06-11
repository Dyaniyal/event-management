class AddTwitterSocialTagsAndFacebookSocialTagsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :twitter_social_tags, :string
    add_column :events, :facebook_social_tags, :string
  end
end
