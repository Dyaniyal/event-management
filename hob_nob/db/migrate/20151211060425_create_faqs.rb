class CreateFaqs < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
    	t.text :question
    	t.text :answer
    	t.integer :event_id
    	t.integer :user_id

      t.timestamps null: false
    end
  end
end
