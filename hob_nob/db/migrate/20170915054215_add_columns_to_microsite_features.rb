class AddColumnsToMicrositeFeatures < ActiveRecord::Migration
  def change
  	add_column :microsite_features, :menu_visibilty, :string
  	add_column :microsite_features, :menu_icon_visibility, :string
  end
end
