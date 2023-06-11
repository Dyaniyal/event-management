class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer :invitee_id
      t.string :favoritable_type
      t.integer :favoritable_id
      t.string :status, :default => "active"

      t.timestamps null: false
    end
  end
end
