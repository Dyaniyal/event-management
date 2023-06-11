class AddAutoApprovedToRegistrationSettings < ActiveRecord::Migration
  def change
    add_column :registration_settings, :auto_approved, :string
  end
end
