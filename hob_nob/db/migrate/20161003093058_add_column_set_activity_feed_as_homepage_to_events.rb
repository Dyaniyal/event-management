class AddColumnSetActivityFeedAsHomepageToEvents < ActiveRecord::Migration
  def change
    add_column :events, :set_activity_feed_as_homepage, :boolean
  end
end
