class AddAppIconSplashScreenToMobileApplication < ActiveRecord::Migration
  def change
    add_attachment :mobile_applications, :app_icon
    add_attachment :mobile_applications, :splash_screen
  end
end