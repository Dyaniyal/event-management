class AddTrankLinkInEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :track_link_6_id, :string
  end
end
