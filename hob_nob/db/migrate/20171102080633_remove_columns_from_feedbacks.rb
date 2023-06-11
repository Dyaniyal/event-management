class RemoveColumnsFromFeedbacks < ActiveRecord::Migration
  def change
  	remove_column :feedbacks, :show_feedback_feature, :string
  	remove_column :feedbacks, :group_ids, :text
  end
end
