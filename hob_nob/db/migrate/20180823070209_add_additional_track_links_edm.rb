class AddAdditionalTrackLinksEdm < ActiveRecord::Migration
  def change
  	add_column :edms, :track_link_7_id, :string
  	add_column :edms, :track_link_8_id, :string
  	add_column :edms, :track_link_9_id, :string
  	add_column :edms, :track_link_10_id, :string  	
  end
end
