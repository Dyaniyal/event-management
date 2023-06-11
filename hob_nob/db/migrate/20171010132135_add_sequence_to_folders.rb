class AddSequenceToFolders < ActiveRecord::Migration
  def change
    add_column :folders, :sequence, :integer
  end
end
