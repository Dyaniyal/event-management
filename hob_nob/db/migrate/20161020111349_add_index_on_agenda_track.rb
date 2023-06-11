class AddIndexOnAgendaTrack < ActiveRecord::Migration
  def change
    add_index :agenda_tracks, :id
  end
end
