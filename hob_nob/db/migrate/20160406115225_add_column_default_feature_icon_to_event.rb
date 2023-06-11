class AddColumnDefaultFeatureIconToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :default_feature_icon, :string, default: "custom"
  end
end
