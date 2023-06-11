class AddParentIdInGroupings < ActiveRecord::Migration
  def change
  	add_column :groupings, :parent_id, :integer
  end
end
