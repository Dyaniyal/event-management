class AddColumnUserQuizzesCountCacheToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :user_quizzes_count_cache, :integer, :default => 0
  end
end
