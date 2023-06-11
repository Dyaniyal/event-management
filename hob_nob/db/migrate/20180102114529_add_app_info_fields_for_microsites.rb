class AddAppInfoFieldsForMicrosites < ActiveRecord::Migration
  def change
  	add_attachment :microsites, :app_icon
  	add_column :microsites, :social_media_status, :string
  	add_column :microsites, :social_media_logins, :string
  	add_column :microsites, :background_color, :string
  end
end
