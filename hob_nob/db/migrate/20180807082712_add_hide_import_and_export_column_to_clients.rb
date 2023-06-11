class AddHideImportAndExportColumnToClients < ActiveRecord::Migration
  def change
  	add_column :clients, :hide_import, :string, :default => "no"
  	add_column :clients, :hide_export, :string, :default => "no"
  end
end
