class AddCssJsSourceToRegistrations < ActiveRecord::Migration
  def change
  	add_column :registrations, :custom_css, :text
  	add_column :registrations, :custom_js, :text
  	add_column :registrations, :custom_source_code, :text
  end
end
