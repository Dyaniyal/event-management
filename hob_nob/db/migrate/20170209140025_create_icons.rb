class CreateIcons < ActiveRecord::Migration
  def change
    create_table :icons do |t|
      t.integer :icon_library_id
      t.string :icon_name
      t.attachment :menu_icon
      t.attachment :main_icon
      t.timestamps null: false
    end
  end
end
