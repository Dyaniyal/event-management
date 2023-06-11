class CreateStoreScreenshots < ActiveRecord::Migration
  def change
    create_table :store_screenshots do |t|
      t.integer :store_info_id
      t.string :platform
      t.string :screen_type
      t.string :screen_name
      t.string :screen_size

      t.string :screen_file_name, limit: 255
      t.string :screen_content_type, limit: 255
      t.integer :screen_file_size, limit: 4
      t.datetime :screen_updated_at

      t.timestamps null: false
    end
  end
end
