class AddEventIdToFavorites < ActiveRecord::Migration
  def change
    add_column :favorites, :event_id, :integer
  end
end
