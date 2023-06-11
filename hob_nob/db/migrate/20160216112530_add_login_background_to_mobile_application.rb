class AddLoginBackgroundToMobileApplication < ActiveRecord::Migration
  def change
  	add_attachment :mobile_applications, :login_background
    add_attachment :mobile_applications, :listing_screen_background
  end
end
