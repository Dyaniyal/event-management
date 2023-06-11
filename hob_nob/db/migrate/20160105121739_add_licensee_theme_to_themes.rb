class AddLicenseeThemeToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :licensee_theme, :boolean
  end
end
