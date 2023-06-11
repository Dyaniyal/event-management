class AddPreviewThemeToThemes < ActiveRecord::Migration
  def change
  	add_column :themes, :preview_theme, :string, :default => "no"
  end
end
