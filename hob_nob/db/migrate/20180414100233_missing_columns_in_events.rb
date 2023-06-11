class MissingColumnsInEvents < ActiveRecord::Migration
  def change
  	add_column :events, :custom_content, :string
  	add_column :events, :copy_content, :string
  	add_column :events, :copy_event, :string
  	add_column :events, :instagram_access_token, :string
  	add_column :events, :instagram_code, :string
  	add_column :events, :copy_content_button, :string
  end
end
