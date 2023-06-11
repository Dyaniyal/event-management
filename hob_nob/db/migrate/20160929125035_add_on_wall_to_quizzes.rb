class AddOnWallToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :on_wall, :string
  end
end
