class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
    t.integer :event_id
    t.string  :title
    t.text		:description
    t.timestamps null: false
    end
  end
end
