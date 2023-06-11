class AddIndicesOnLastUpdatedModels < ActiveRecord::Migration
  def change
    add_index :last_updated_models, :model_name
    add_index :last_updated_models, :last_updated
    add_index :last_updated_models, [:model_name, :last_updated]
  end
end
