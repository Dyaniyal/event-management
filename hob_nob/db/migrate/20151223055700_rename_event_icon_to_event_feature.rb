class RenameEventIconToEventFeature < ActiveRecord::Migration
  def change
  	rename_table :event_icons, :event_features
  end
end
