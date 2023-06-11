class AddIndexToSequenceToFeedbackForms < ActiveRecord::Migration
  def change
  	add_index :feedback_forms, :sequence
  end
end
