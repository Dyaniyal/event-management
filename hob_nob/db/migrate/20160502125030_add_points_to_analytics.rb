class AddPointsToAnalytics < ActiveRecord::Migration
  def change
    add_column :analytics, :points, :integer
  end
end
