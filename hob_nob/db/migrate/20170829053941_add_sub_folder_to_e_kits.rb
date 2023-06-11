class AddSubFolderToEKits < ActiveRecord::Migration
  def change
    add_column :e_kits, :sub_folder, :string
  end
end
