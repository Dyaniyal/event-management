class CreatePanels < ActiveRecord::Migration
  def change
    create_table :panels do |t|
      t.string :name
      t.integer :event_id
      t.integer :panel_id
      t.string :panel_type
      t.timestamps null: false
    end
  end
end