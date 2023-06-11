class AddColumnsToCustomPages6to10 < ActiveRecord::Migration
  def change
  	for x in 6..10 do
  		add_column "custom_page#{x}s", :language_updated, :boolean
  		add_column "custom_page#{x}s", :multi_lng_parent_id, :integer
  	end
  end
end
