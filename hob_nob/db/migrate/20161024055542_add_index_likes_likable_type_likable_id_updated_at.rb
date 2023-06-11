class AddIndexLikesLikableTypeLikableIdUpdatedAt < ActiveRecord::Migration
  def change
    add_index :likes, [:likable_type, :likable_id, :updated_at]
  end
end
