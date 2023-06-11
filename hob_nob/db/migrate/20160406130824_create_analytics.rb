class CreateAnalytics < ActiveRecord::Migration
  def change
    create_table :analytics do |t|
      t.string :viewable_type
      t.integer :viewable_id
      t.string :action
      t.integer :invitee_id
      t.integer :event_id

      t.timestamps null: false
    end
  end
end
