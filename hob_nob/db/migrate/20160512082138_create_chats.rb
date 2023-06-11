class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
    	t.string :chat_type
      t.integer :sender_id
      t.string :member_ids
      t.datetime :date_time
      t.integer :event_id
      t.timestamps null: false
    end
  end
end
