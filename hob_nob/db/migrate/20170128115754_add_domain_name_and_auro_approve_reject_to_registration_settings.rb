class AddDomainNameAndAuroApproveRejectToRegistrationSettings < ActiveRecord::Migration
  def change
  	add_column :registration_settings, :auto_rejected, :string
  	add_column :registration_settings, :auto_rejected_domain_validation, :text
  	add_column :registration_settings, :auto_approved_domain_validation, :text
  	add_column :registration_settings, :target_registration, :string
  end
end
