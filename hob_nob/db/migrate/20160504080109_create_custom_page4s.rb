class CreateCustomPage4s < ActiveRecord::Migration
  def change
    create_table :custom_page4s do |t|
      t.integer :event_id
      t.string :page_type
      t.string :site_url
      t.text :description

      t.timestamps null: false
    end
  end
end
