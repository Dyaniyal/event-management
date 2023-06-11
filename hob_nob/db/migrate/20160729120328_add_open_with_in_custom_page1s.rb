class AddOpenWithInCustomPage1s < ActiveRecord::Migration
  def change
  	add_column :custom_page1s, :open_with, :string
  end
end
