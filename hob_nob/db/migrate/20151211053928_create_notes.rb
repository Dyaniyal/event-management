class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
    	t.text :description
    	t.datetime :date
    	t.integer :event_id

      t.timestamps null: false
    end
  end
end
