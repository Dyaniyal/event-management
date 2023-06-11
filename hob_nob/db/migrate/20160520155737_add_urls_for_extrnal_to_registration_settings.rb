class AddUrlsForExtrnalToRegistrationSettings < ActiveRecord::Migration
  def change
  	add_column :registration_settings, :external_reg_url, :text
  	add_column :registration_settings, :external_reg_surl, :text
  	add_column :registration_settings, :external_login_url, :text
  	add_column :registration_settings, :external_login_surl, :text
  end
end
