class AddFieldsToSponsor < ActiveRecord::Migration
  def change
  	add_column :sponsors, :way_location, :string
  	add_column :sponsors, :location, :string
  end
end
