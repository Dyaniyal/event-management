class AddMobileApplicationIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :mobile_application_id, :integer
  end
end
