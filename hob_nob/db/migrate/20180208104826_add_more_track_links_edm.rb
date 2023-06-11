class AddMoreTrackLinksEdm < ActiveRecord::Migration
  def change
  	add_column :edms, :track_link_4_id, :string
  	add_column :edms, :track_link_5_id, :string
  end
end
