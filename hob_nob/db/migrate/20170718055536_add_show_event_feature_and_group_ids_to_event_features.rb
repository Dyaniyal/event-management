class AddShowEventFeatureAndGroupIdsToEventFeatures < ActiveRecord::Migration
  def change
    add_column :event_features, :show_event_feature, :string
    add_column :event_features, :group_ids, :text
  end
end
