class AddImportableIdToImports < ActiveRecord::Migration
  def change
    add_column :imports, :importable_id, :integer
  end
end
