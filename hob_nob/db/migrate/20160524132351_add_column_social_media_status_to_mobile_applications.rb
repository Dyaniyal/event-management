class AddColumnSocialMediaStatusToMobileApplications < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :social_media_status, :string, :default => "active"
  end
end
