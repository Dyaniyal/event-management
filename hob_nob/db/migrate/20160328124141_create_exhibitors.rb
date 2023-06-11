class CreateExhibitors < ActiveRecord::Migration
  def change
    create_table :exhibitors do |t|
      t.integer :event_id
      t.string  :exhibitor_type
      t.string  :name
      t.string  :email
      t.text  :description
      t.text  :website_url
      t.string  :image_file_name
      t.string  :image_content_type
      t.integer :image_file_size  
      t.datetime :image_updated_at
      t.timestamps null: false
    end
  end
end
