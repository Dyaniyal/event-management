class ChangeThemeIdDataTypeToInt < ActiveRecord::Migration
  def change
  	change_column :events, :theme_id, :integer
  end
end
