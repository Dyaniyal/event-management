class AddColumnListingScreenTextColor < ActiveRecord::Migration
  def change
  	add_column :mobile_applications, :listing_screen_text_color, :string
  end
end
