class AddBackgroundImageToTheme < ActiveRecord::Migration
  def change
  	add_attachment :themes, :event_background_image
  end
end
