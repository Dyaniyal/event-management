class AddColumnLikesCountCacheToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :likes_count_cache, :integer
  end
end
