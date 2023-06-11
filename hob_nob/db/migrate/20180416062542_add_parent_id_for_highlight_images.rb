class AddParentIdForHighlightImages < ActiveRecord::Migration
  def change
  	add_column :highlight_images, :parent_id, :integer
  end
end
