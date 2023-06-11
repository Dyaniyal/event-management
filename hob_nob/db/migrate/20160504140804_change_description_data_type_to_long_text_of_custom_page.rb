class ChangeDescriptionDataTypeToLongTextOfCustomPage < ActiveRecord::Migration
  def change
  	change_column :custom_page1s, :description, :text, :limit => 4294967295
  	change_column :custom_page2s, :description, :text, :limit => 4294967295
  	change_column :custom_page3s, :description, :text, :limit => 4294967295
  	change_column :custom_page4s, :description, :text, :limit => 4294967295
  	change_column :custom_page5s, :description, :text, :limit => 4294967295
  end
end
