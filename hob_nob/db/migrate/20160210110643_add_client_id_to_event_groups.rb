class AddClientIdToEventGroups < ActiveRecord::Migration
  def change
    add_column :event_groups, :client_id, :integer
  end
end
