class AddColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :microsite_map, :string
  end
end
