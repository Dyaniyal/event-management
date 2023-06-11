class ChangeDafaultValueOfSocialMediaStatusToMobileApplications < ActiveRecord::Migration
  def change
  	change_column_default :mobile_applications, :social_media_status, nil
  end
end
