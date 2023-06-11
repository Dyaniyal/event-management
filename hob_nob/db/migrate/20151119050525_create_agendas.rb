class CreateAgendas < ActiveRecord::Migration
  def change
    create_table :agendas do |t|
      t.string :event_name
      t.string :event_time
      t.string :speaker_name
      t.string :options
      t.references :event, index: true, foreign_key: true


      t.timestamps null: false
    end
  end
end
