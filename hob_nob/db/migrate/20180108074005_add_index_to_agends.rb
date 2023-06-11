class AddIndexToAgends < ActiveRecord::Migration
  def change
  	add_index :agendas, [:event_id, :updated_at]
  	add_index :event_features, :show_event_feature
    add_index :speakers, :show_speaker_feature
    add_index :polls, :show_poll_feature
    add_index :quizzes, :show_quiz_feature
    add_index :e_kits, :show_e_kit_feature
    add_index :feedback_forms, :show_feedback_feature
    add_index :agendas, :show_agenda_feature
  end
end
