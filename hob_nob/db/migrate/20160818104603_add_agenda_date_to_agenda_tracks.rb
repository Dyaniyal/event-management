class AddAgendaDateToAgendaTracks < ActiveRecord::Migration
  def change
    add_column :agenda_tracks, :agenda_date, :date
  end
end
