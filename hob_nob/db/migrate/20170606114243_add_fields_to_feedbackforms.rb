class AddFieldsToFeedbackforms < ActiveRecord::Migration
  def change
  	add_column :feedback_forms, :submission_msg, :text
  end
end
