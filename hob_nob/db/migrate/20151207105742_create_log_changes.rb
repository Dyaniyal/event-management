class CreateLogChanges < ActiveRecord::Migration
  def change
    create_table :log_changes do |t|
      t.text :changed_data
      t.integer :user_id
      t.string :resourse_type
      t.integer :resourse_id

      t.timestamps null: false
    end
  end
end
