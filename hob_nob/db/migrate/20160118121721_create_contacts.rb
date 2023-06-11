class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :event_id
      t.string :email
      t.string :name
      t.string :mobile

      t.timestamps null: false
    end
  end
end
