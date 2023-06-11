class AddMenuSavedToMicrosites < ActiveRecord::Migration
  def change
    add_column :microsites, :menu_saved, :string
  end
end
