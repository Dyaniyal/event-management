class AddRegisterVisitorToMobileApplications < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :visitor_registration, :string 
  	add_column :mobile_applications, :visitor_registration_background_color, :string 
  	add_attachment :mobile_applications, :visitor_registration_background_image
  end
end
