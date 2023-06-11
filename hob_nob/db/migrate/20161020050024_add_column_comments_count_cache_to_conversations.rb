class AddColumnCommentsCountCacheToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :comments_count_cache, :integer
  end
end
