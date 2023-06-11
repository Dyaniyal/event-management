class CreateTrackLinkUsers < ActiveRecord::Migration
  def change
    create_table :track_link_users do |t|
      t.string :email
      t.integer :event_id
      t.integer :track_link_id
      t.integer :edm_id
      t.string  :track_link_no
      
      t.timestamps null: false
    end
  end
end
