class ChangeDefaultValueOffLib < ActiveRecord::Migration
  def change
  	change_column :events, :default_feature_icon, :string, :default => "new_menu"
  end
end
