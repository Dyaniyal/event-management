class AddPublishedByHobnobToStoreInfos < ActiveRecord::Migration
  def change
    add_column :store_infos, :published_by_hobnob, :string
  end
end
