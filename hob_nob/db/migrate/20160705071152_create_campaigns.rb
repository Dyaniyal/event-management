class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.integer  "event_id"
      t.string   "campaign_name"
      t.timestamps null: false
    end
  end
end
