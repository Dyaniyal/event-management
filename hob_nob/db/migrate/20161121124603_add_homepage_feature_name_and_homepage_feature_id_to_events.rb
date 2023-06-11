class AddHomepageFeatureNameAndHomepageFeatureIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :homepage_feature_name, :string
    add_column :events, :homepage_feature_id, :integer
  end
end
