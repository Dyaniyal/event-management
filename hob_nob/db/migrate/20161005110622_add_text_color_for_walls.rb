class AddTextColorForWalls < ActiveRecord::Migration
  def change
    add_column :qna_walls, :sub_text_color, :string
    add_column :conversation_walls, :sub_text_color, :string
    add_column :poll_walls, :sub_text_color, :string
    add_column :quiz_walls, :sub_text_color, :string
  end
end
