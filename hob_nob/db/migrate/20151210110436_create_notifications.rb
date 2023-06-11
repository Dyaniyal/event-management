class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string  :name
      t.integer :resourceable_id
      t.string  :resourceable_type
      t.string  :action
      t.integer :sender_id
      t.integer :receiver_id
      t.boolean  :open, :default => false
      t.boolean  :unread, :default => true
      t.string  :status
      t.timestamps null: false
    end
  end
end
