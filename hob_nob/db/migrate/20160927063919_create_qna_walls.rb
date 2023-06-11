class CreateQnaWalls < ActiveRecord::Migration
  def change
    create_table :qna_walls do |t|
      t.integer :event_id
      t.string :bg_color
      t.string :tab_color
      t.string :font_color
      t.string :title

      t.timestamps null: false
    end
  end
end
