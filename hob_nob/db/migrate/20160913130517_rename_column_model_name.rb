class RenameColumnModelName < ActiveRecord::Migration
  def change
    rename_column :last_updated_models, :model_name, :name
  end
end
