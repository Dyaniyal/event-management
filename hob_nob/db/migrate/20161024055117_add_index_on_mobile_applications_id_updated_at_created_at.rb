class AddIndexOnMobileApplicationsIdUpdatedAtCreatedAt < ActiveRecord::Migration
  def change
    add_index :mobile_applications, [:id, :updated_at, :created_at]
  end
end
