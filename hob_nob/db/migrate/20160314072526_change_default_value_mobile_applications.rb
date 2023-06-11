class ChangeDefaultValueMobileApplications < ActiveRecord::Migration
  def change
  	change_column_default :mobile_applications, :status, nil
  end
end
