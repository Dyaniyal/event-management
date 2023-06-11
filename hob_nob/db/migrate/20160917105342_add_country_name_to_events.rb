class AddCountryNameToEvents < ActiveRecord::Migration
  def change
    add_column :events, :country_name, :string
  end
end
