class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.integer :licensee_id
      t.string :name
      t.string :background_color
      t.string :skin_image
      t.string :content_font_color
      t.string :button_color
      t.string :button_content_color
      t.string :drawer_menu_back_color
      t.string :drawer_menu_font_color

      t.timestamps null: false
    end
  end
end
