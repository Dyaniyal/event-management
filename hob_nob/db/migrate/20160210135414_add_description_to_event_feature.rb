class AddDescriptionToEventFeature < ActiveRecord::Migration
  def change
  	add_column :event_features, :description, :text
  end
end
