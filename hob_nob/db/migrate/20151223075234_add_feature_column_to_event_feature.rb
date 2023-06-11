class AddFeatureColumnToEventFeature < ActiveRecord::Migration
  def change
  	add_column :event_features, :page_title, :string
  	add_column :event_features, :status, :string , :default => "active"
  	add_column :event_features, :sequence, :integer
  end
end
