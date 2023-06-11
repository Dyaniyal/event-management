class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string :token
      t.string :platform
      t.boolean :enabled

      t.timestamps null: false
    end
  end
end
