class AddColumnLastUpdateCommentToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :last_update_comment_description, :string
  end
end
