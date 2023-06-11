class AddLoginBackgroundColorToMobileApplication < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :login_background_color, :string
  	add_column :mobile_applications, :message_above_login_page, :text
  	add_column :mobile_applications, :registration_message, :text
  	add_column :mobile_applications, :registration_link, :text
  end
end
