class AddColumnAgendaIdsToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :agenda_ids, :string
  end
end
