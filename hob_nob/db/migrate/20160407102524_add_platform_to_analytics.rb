class AddPlatformToAnalytics < ActiveRecord::Migration
  def change
    add_column :analytics, :platform, :string
  end
end
