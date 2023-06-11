class AddLastInteractionAtToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :last_interaction_at, :datetime
  end
end
