class AddFeatureToEKits < ActiveRecord::Migration
  def change
  	add_column :e_kits, :show_e_kit_feature, :string
    add_column :e_kits, :group_ids, :text
  end
end
