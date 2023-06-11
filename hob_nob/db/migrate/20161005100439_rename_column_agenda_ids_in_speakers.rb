class RenameColumnAgendaIdsInSpeakers < ActiveRecord::Migration
  def change
  	rename_column :speakers, :agenda_ids, :all_agenda_ids
  end
end
