class AddColumnAllSpeakerNamesToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :all_speaker_names, :text
  end
end
