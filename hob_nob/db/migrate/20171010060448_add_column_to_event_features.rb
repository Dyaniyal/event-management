class AddColumnToEventFeatures < ActiveRecord::Migration
  def change
    add_column :event_features, :image_setting, :string
  end
end
