class AddTrackLinkIdsToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :track_link_1_id, :string
  	add_column :edms, :track_link_2_id, :string
  	add_column :edms, :track_link_3_id, :string
  end
end
