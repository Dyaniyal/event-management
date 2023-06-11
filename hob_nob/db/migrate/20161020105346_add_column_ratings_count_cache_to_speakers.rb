class AddColumnRatingsCountCacheToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :ratings_count_cache, :integer
  end
end
