class CreateEventGroups < ActiveRecord::Migration
  def change
    create_table :event_groups do |t|
      t.string :name
      t.text :remarks

      t.timestamps null: false
    end
  end
end
