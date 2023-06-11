class AddColumnShowSocialFeedInEvents < ActiveRecord::Migration
  def change
    add_column :events, :show_social_feed, :boolean
  end
end
