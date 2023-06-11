class AddColumnMenuSavedToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :menu_saved, :string
  end
end
