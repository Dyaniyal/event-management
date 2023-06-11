class RenameColumnLicenseeStatus < ActiveRecord::Migration
  def change
  	rename_column :users, :licensee_status, :status
  end
end
