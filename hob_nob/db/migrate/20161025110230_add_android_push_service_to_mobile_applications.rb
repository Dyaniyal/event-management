class AddAndroidPushServiceToMobileApplications < ActiveRecord::Migration
  def change
    add_column :mobile_applications, :android_push_service, :string
  end
end
