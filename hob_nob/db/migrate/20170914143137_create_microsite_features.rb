class CreateMicrositeFeatures < ActiveRecord::Migration
  def change
    create_table :microsite_features do |t|
      t.string   :name
      t.integer  :event_id
      t.string   :menu_icon_file_name
      t.string   :menu_icon_content_type
      t.integer  :menu_icon_file_size
      t.datetime :menu_icon_updated_at
      t.string   :main_icon_file_name
      t.string   :main_icon_content_type
      t.integer  :main_icon_file_size
      t.datetime :main_icon_updated_at
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :page_title
      t.string   :status
      t.text     :description
      
      t.timestamps null: false
    end
  end
end
