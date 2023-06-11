class CreateGroupings < ActiveRecord::Migration
  def change
    create_table :groupings do |t|
    	t.integer :event_id
      t.string :name
      t.text :condition
      t.timestamps null: false
    end
  end
end