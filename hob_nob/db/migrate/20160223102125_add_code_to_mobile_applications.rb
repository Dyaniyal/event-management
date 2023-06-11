class AddCodeToMobileApplications < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :code, :string
  end
end
