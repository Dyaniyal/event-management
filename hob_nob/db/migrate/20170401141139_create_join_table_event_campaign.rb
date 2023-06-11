class CreateJoinTableEventCampaign < ActiveRecord::Migration
  def change
    create_join_table :events, :campaigns do |t|
      t.index [:event_id, :campaign_id]
      t.index [:campaign_id, :event_id]
    end
  end
end
