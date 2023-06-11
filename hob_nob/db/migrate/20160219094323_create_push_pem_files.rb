class CreatePushPemFiles < ActiveRecord::Migration
  def change
    create_table :push_pem_files do |t|
      t.integer  :mobile_application_id
      t.string :title
      t.string :pass_phrase
      t.string :push_url
      t.text :android_push_key
      t.string   :pem_file_file_name
      t.string   :pem_file_content_type
      t.integer  :pem_file_file_size
      t.datetime :pem_file_updated_at

      t.timestamps null: false
    end
  end
end
