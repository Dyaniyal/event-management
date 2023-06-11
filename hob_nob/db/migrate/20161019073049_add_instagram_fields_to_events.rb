class AddInstagramFieldsToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :instagram_social_tags, :string
  	add_column :events, :instagram_client_id, :string
  end
end
