class AddSocialsToMobileApplications < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :social_media_logins, :string
  end
end
