class CreateConversationWalls < ActiveRecord::Migration
  def change
    create_table :conversation_walls do |t|
      t.string :background_color
      t.string :box_color
      t.string :font_color

      t.timestamps null: false
    end
  end
end
