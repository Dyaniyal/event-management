class AddIndexingIntoQuizzAndAnalyticModel < ActiveRecord::Migration
  def change
  	add_index :quizzes, :question, :name => "index_on_question_in_quizzes",:length => 255
  	add_index :quizzes, [:event_id], :name => "index_on_event_id_in_quizzes"

  	add_index :analytics, [:action], :name => "index_on_action_in_analytics"
  	add_index :analytics, [:viewable_type], :name => "index_on_viewable_type_in_analytics"
  	add_index :analytics, [:viewable_id], :name => "index_on_viewable_id_in_analytics"
  	add_index :analytics, [:invitee_id], :name => "index_on_invitee_id_in_analytics"
  	add_index :analytics, [:event_id], :name => "index_on_event_id_in_analytics"
  	add_index :analytics, [:platform], :name => "index_on_platform_in_analytics"
  end
end
