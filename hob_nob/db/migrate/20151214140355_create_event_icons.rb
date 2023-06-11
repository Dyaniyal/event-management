class CreateEventIcons < ActiveRecord::Migration
  def change
    create_table :event_icons do |t|
      t.string :name
      t.integer :event_id
      t.string :menu_icon_file_name
      t.string :menu_icon_content_type
      t.integer :menu_icon_file_size
      t.datetime :menu_icon_updated_at

      t.string :main_icon_file_name
      t.string :main_icon_content_type
      t.integer :main_icon_file_size
      t.datetime :main_icon_updated_at
      t.timestamps null: false
    end
  end
end
