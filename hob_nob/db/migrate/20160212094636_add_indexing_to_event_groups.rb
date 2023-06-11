class AddIndexingToEventGroups < ActiveRecord::Migration
  def change
  	add_index :event_groups, [:name], :name => "index_name_on_event_groups"
  end
end
