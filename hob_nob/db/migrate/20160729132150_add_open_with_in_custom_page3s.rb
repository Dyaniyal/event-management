class AddOpenWithInCustomPage3s < ActiveRecord::Migration
  def change
  	add_column :custom_page3s, :open_with, :string
  end
end
