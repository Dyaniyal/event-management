class AddFeedbackFormIdToUserFeedbacks < ActiveRecord::Migration
  def change
  	add_column :user_feedbacks, :feedback_form_id, :integer
  end
end
