class AddColumnsToAgendaTrack < ActiveRecord::Migration
  def change
    add_column :agenda_tracks, :event_id, :integer
    add_column :agenda_tracks, :sequence, :integer
  end
end
