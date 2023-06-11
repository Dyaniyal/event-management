class CreateAgendaTracks < ActiveRecord::Migration
  def change
    create_table :agenda_tracks do |t|
      t.string :track_name

      t.timestamps null: false
    end
  end
end
