class RemoveColumnFromMicrosites < ActiveRecord::Migration
  def change
  	remove_column :microsite_look_and_feels, :home_page_content, :string
  end
end
