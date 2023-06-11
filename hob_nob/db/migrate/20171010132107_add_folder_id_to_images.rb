class AddFolderIdToImages < ActiveRecord::Migration
  def change
    add_column :images, :folder_id, :integer
  end
end
