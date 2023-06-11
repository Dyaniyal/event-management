class AddSubmittedIdToMobileApplication < ActiveRecord::Migration
  def change
  	rename_column :mobile_applications, :code, :submitted_code
  	add_column :mobile_applications, :preview_code, :string
  	add_column :mobile_applications, :status, :string, :default => "composed"
  end
end
