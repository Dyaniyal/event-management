class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :likable_id
      t.string  :likable_type
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
