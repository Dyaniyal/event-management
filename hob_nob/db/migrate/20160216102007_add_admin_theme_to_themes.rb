class AddAdminThemeToThemes < ActiveRecord::Migration
  def change
    add_column :themes, :admin_theme, :boolean
  end
end
