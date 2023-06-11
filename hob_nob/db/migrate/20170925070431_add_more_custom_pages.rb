class AddMoreCustomPages < ActiveRecord::Migration
  def change
  	5.times do |p|
      create_table "custom_page#{p+6}s" do |t|
        t.integer :event_id
        t.string :page_type
        t.string :site_url
        t.text :description
        t.string :open_with
        # t.integer :parent_id
        # t.integer :multi_lng_parent_id
        # t.boolean :language_updated

        t.timestamps null: false
      end
    end
  end
end
