class AddAgendaTrackIdToAgenda < ActiveRecord::Migration
  def change
    add_column :agendas, :agenda_track_id, :integer
  end
end
