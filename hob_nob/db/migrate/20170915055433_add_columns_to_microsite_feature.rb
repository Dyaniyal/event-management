class AddColumnsToMicrositeFeature < ActiveRecord::Migration
  def change
  	add_column :microsite_features, :interpolate_time_stamp, :string
  	add_column :microsite_features, :main_icon_interpolate_time_stamp, :string
  end
end
