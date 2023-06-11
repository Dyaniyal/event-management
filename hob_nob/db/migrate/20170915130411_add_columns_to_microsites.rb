class AddColumnsToMicrosites < ActiveRecord::Migration
  def change
  	add_column :microsites, :default_feature_icon, :string
  	add_column :microsites, :homepage_feature_name, :string
  	add_column :microsites, :homepage_feature_id, :integer
  end
end
