class AddOpenWithInCustomPage4s < ActiveRecord::Migration
  def change
  	add_column :custom_page4s, :open_with, :string
  end
end
