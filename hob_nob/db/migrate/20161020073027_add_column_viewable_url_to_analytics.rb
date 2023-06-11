class AddColumnViewableUrlToAnalytics < ActiveRecord::Migration
  def change
  	add_column :analytics, :viewable_url, :string
  end
end
