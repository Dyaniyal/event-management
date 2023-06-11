class AddFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :google_map_link, :string
    add_column :events, :remarks, :text
  end
end
