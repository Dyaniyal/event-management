class AddIndexingOnTextFieldHavingConditionAndActionFieldOnLogchanges < ActiveRecord::Migration
  def change
  	add_index :conversations, :description, :name => "index_on_description_in_conversations",:length => 255

  	add_index :faqs, :question, :name => "index_on_question_in_faqs",:length => 255
  	add_index :faqs, :answer, :name => "index_on_answer_in_faqs",:length => 255

  	add_index :log_changes, [:action], :name => "index_on_action_in_log_changes"

  	add_index :polls, :question, :name => "index_on_question_in_polls",:length => 255

  	add_index :qnas, :question, :name => "index_on_question_in_qnas",:length => 255
  end
end
