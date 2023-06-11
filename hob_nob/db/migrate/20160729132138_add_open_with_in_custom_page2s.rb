class AddOpenWithInCustomPage2s < ActiveRecord::Migration
  def change
  	add_column :custom_page2s, :open_with, :string
  end
end
