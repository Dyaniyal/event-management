class AddTitleColorToQnaWalls < ActiveRecord::Migration
  def change
    add_column :qna_walls, :title_color, :string
  end
end
