class CreateTelecallerGroups < ActiveRecord::Migration
  def change
    create_table :telecaller_groups do |t|
      t.string :assign_grouping
      t.integer :target_assigned
      t.integer :registration_target
      t.integer :event_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
