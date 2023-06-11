class AddMultiLngParentIdToMissingModels < ActiveRecord::Migration
  def change
  	add_column :edms, :multi_lng_parent_id, :integer
  	add_column :campaigns, :multi_lng_parent_id, :integer
  end
end
