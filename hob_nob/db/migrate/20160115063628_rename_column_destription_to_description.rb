class RenameColumnDestriptionToDescription < ActiveRecord::Migration
  def change
  	rename_column :feedbacks, :destription, :description
  end
end
