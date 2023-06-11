class AddTrackLinkNoToTrackLinks < ActiveRecord::Migration
  def change
  	add_column :track_links, :track_link_no, :string
  end
end
