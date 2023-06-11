class ChangeDataTypeQuizzes < ActiveRecord::Migration
  def change
  	change_column :quizzes, :sequence, :integer
  end
end
