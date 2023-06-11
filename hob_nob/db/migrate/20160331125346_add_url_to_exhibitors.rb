class AddUrlToExhibitors < ActiveRecord::Migration
  def change
  	add_column :exhibitors, :url, :text
  end
end
