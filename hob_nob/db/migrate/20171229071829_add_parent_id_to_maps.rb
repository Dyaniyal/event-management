class AddParentIdToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :parent_id, :integer
    add_column :qna_settings, :parent_id, :integer
    add_column :themes, :parent_id, :integer
  end
end
