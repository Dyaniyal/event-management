class AddIndexingToFeedbacks < ActiveRecord::Migration
  def change
  	add_index :feedbacks, [:question], :name => "index_question_on_feedbacks"
  end
end
