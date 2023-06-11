class AddFeedbackFormIdToFeedbacks < ActiveRecord::Migration
  def change
  	add_column :feedbacks, :feedback_form_id, :integer
  end
end
