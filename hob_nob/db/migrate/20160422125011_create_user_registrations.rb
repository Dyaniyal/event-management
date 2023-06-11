class CreateUserRegistrations < ActiveRecord::Migration
  def change
    create_table :user_registrations do |t|
      t.integer :registration_id
      t.integer :invitee_id
      t.integer :event_id
      t.string :field1
      t.string :field2
      t.string :field3
      t.string :field4
      t.string :field5
      t.string :field6
      t.string :field7
      t.string :field8
      t.string :field9
      t.string :field10
      t.string :field11
      t.string :field12
      t.string :field13
      t.string :field14
      t.string :field15

      t.timestamps null: false
    end
  end
end
