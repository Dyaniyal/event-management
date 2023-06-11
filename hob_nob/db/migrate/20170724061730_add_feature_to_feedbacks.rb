class AddFeatureToFeedbacks < ActiveRecord::Migration
  def change
  	add_column :feedbacks, :show_feedback_feature, :string
    add_column :feedbacks, :group_ids, :text
  end
end
