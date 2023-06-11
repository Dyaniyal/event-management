class AddPrivacyFieldsToMobileApplications < ActiveRecord::Migration
  def change

  	add_column :mobile_applications, :agreeing_terms_and_conditions, :string
  	add_column :mobile_applications, :user_agreement_text, :string
  	add_column :mobile_applications, :url_1_text, :string
  	add_column :mobile_applications, :url_1_link, :string
  	add_column :mobile_applications, :url_2_text, :string
  	add_column :mobile_applications, :url_2_link, :string
  end
end
