class AddLoginAtToMobileApplication < ActiveRecord::Migration
  def change
    add_column :mobile_applications, :login_at, :string, :default => "Yes"
  end
end
