class AddCorrectAnswerToQuiz < ActiveRecord::Migration
  def change
  	add_column :quizzes, :correct_answer, :string
  end
end
