class CreateMyTravels < ActiveRecord::Migration
  def change
    create_table :my_travels do |t|
      t.string :invitee_id
      t.references :event, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
