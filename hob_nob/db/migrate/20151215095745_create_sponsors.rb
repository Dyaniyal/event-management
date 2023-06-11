class CreateSponsors < ActiveRecord::Migration
  def change
    create_table :sponsors do |t|
    	t.integer :event_id
    	t.string  :sponsor_type
      t.timestamps null: false
    end
  end
end
