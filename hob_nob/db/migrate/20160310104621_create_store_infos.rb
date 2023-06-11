class CreateStoreInfos < ActiveRecord::Migration
  def change
    create_table :store_infos do |t|
      t.string :mobile_application_id
      t.string :is_android_app
      t.string :is_ios_app

      t.string :android_title
      t.string :android_short_desc
      t.text :android_full_desc
      t.string :android_app_type
      t.string :android_category
      t.string :android_content_rating
      t.string :android_website
      t.string :android_email
      t.string :android_phone
      t.text :android_policy_url
      t.text :android_country_list
      t.string :android_contains_ads
      t.string :android_content_guideline
      t.string :android_us_export_laws

      t.string   :android_app_icon_file_name, limit: 255
      t.string   :android_app_icon_content_type, limit: 255
      t.integer  :android_app_icon_file_size, limit: 4
      t.datetime :android_app_icon_updated_at

      t.string :ios_title
      t.string :ios_language
      t.string :ios_bundle_id
      t.string :ios_title
      t.string :ios_sku
      t.string :ios_keyword
      t.string :ios_support_url
      t.string :ios_copyright
      t.string :ios_contact_first_name
      t.string :ios_contact_last_name
      t.string :ios_contact_email
      t.string :ios_contact_phone
      t.string :ios_demo_email
      t.string :ios_password
      t.text :ios_notes

      t.string   :ios_app_icon_file_name, limit: 255
      t.string   :ios_app_icon_content_type, limit: 255
      t.integer  :ios_app_icon_file_size, limit: 4
      t.datetime :ios_app_icon_updated_at

      t.timestamps null: false
    end
  end
end
