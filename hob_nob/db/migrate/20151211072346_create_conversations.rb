class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.text 	:description
      t.integer :event_id
      t.integer :user_id
      t.string  :image_file_name
      t.string	:image_content_type
      t.string	:image_file_size
      t.datetime :image_updated_at
      t.timestamps null: false
    end
  end
end
