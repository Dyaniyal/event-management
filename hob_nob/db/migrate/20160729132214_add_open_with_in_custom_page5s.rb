class AddOpenWithInCustomPage5s < ActiveRecord::Migration
  def change
  	add_column :custom_page5s, :open_with, :string
  end
end
