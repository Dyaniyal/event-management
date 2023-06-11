class AddFeatureToQuizzes < ActiveRecord::Migration
  def change
  	add_column :quizzes, :show_quiz_feature, :string
    add_column :quizzes, :group_ids, :text
  end
end
