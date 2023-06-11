class AddTwitterHandlesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :twitter_handle, :string
    add_column :events, :show_social_feeds, :boolean
    add_column :events, :last_tweet_date, :datetime 
  end
end
