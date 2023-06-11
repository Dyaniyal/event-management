class AddColumnFromMicrosites < ActiveRecord::Migration
  def change
  	add_column :microsite_look_and_feels, :home_page_content, :text
  end
end
