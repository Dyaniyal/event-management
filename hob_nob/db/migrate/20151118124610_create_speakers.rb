class CreateSpeakers < ActiveRecord::Migration
  def change
    create_table :speakers do |t|
      t.string :event_name
      t.string :speaker_name
      t.string :designation
      t.string :email_address
      t.text :address
      t.text :speaker_info
      t.string :rating
      t.text :feedback
      t.references :event, index: true, foreign_key: true
      

      t.timestamps null: false
    end
  end
end
