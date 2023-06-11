class AddParentIdToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :parent_id, :integer
  end
end
