class CreateMicrosites < ActiveRecord::Migration
  def change
    create_table :microsites do |t|
      t.string :name
      t.integer :event_id

      t.timestamps null: false
    end
  end
end
