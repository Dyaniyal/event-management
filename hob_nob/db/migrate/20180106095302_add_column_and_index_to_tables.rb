class AddColumnAndIndexToTables < ActiveRecord::Migration
  def change
  	add_column :e_kits, :folder_name_cache, :string
  	for i in 1..10 
  		add_index "custom_page#{i}s", :event_id
  	end
  end
end
