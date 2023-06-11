class CreateAgendaSpeakers < ActiveRecord::Migration
  def change
    create_table :agenda_speakers do |t|
      t.integer :agenda_id
      t.integer :speaker_id
      t.string :speaker_name 
      t.timestamps null: false
    end
  end
end
