class AddCacheColumnToAgendas < ActiveRecord::Migration
  def change
  	add_column :agendas, :agenda_track_name_cache, :string
  	add_column :agendas, :agenda_track_sequence_cache, :integer
  end
end
