class AddImportableTypeToImpotrs < ActiveRecord::Migration
  def change
  	add_column :imports, :importable_type, :string
  end
end
