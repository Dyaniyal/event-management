class AddParentIdToPanels < ActiveRecord::Migration
  def change
    add_column :panels, :parent_id, :integer
  end
end
