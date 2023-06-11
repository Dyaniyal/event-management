class CreatePollWalls < ActiveRecord::Migration
  def change
    create_table :poll_walls do |t|
      t.string :background_color
      t.string :bar_color
      t.string :font_color
      t.string :bar_color1
      t.integer :event_id

      t.timestamps null: false
    end
  end
end
