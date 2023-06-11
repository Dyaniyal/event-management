class AddMobileApplicationIdtoEvent < ActiveRecord::Migration
  def change
  	add_column :events, :mobile_application_id, :integer
  end
end
