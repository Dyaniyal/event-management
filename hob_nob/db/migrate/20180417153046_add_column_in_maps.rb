class AddColumnInMaps < ActiveRecord::Migration
  def change
  	add_column :maps, :parent_id, :integer
  end
end
