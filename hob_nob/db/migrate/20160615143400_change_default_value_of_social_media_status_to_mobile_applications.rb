class ChangeDefaultValueOfSocialMediaStatusToMobileApplications < ActiveRecord::Migration
  def change
  	change_column :mobile_applications, :social_media_status, :string, :default=> 'deactive'
  end
end
