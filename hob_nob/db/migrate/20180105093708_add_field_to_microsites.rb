class AddFieldToMicrosites < ActiveRecord::Migration
  def change
    add_column :microsites, :registration_url, :string
    add_column :microsites, :registration_link, :string
  end
end
