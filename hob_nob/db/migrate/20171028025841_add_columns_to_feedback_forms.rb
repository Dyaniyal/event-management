class AddColumnsToFeedbackForms < ActiveRecord::Migration
  def change
  	add_column :feedback_forms, :show_feedback_feature, :string
    add_column :feedback_forms, :group_ids, :text  
  end
end
