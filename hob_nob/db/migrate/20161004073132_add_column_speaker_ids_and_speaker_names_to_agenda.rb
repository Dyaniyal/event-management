class AddColumnSpeakerIdsAndSpeakerNamesToAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :speaker_ids, :string
    add_column :agendas, :speaker_names, :string
  end
end
