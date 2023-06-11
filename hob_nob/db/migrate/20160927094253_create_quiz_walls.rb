class CreateQuizWalls < ActiveRecord::Migration
  def change
    create_table :quiz_walls do |t|
      t.string :background_color
      t.string :bar_color
      t.string :font_color
      t.integer :event_id
      t.string :bar_color1
      t.timestamps null: false
    end
  end
end
