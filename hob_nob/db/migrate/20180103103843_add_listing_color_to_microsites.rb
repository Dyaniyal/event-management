class AddListingColorToMicrosites < ActiveRecord::Migration
  def change
    add_column :microsites, :header_background_color, :string
    add_column :microsites, :footer_background_color, :string
  end
end
