class CreateUserFeedbacks < ActiveRecord::Migration
  def change
    create_table :user_feedbacks do |t|
    	t.integer :feedback_id
    	t.integer :user_id
    	t.string :answer
    	t.text :description
      t.timestamps null: false
    end
  end
end