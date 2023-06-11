class CreateTrackLinks < ActiveRecord::Migration
  def change
    create_table :track_links do |t|
      t.integer  "event_id"
      t.integer  "edm_id"
      t.string   "redirect_link"
      t.string   "regenerate_link"
      t.string   "link_count"
      t.timestamps null: false
    end
  end
end
