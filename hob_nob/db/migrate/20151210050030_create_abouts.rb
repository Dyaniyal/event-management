class CreateAbouts < ActiveRecord::Migration
  def change
    create_table :abouts do |t|
    	t.text :description
    	t.integer :event_id

      t.timestamps null: false
    end
  end
end
