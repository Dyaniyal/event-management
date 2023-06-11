class AddSpeakerIdToAgendas < ActiveRecord::Migration
  def change
    add_column :agendas, :speaker_id, :integer
  end
end
