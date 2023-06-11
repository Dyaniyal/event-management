class AddMenuIconVisibilityToEventFeatures < ActiveRecord::Migration
  def change
  	add_column :event_features, :menu_icon_visibility, :string, :default => "yes"
  end
end
