class AddThemeIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :theme_id, :string
  end
end
