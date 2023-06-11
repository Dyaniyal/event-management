class AddAnalyticIdToComments < ActiveRecord::Migration
  def change
  	add_column :comments, :analytic_id, :integer
  end
end
