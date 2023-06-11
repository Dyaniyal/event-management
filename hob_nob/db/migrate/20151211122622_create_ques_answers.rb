class CreateQuesAnswers < ActiveRecord::Migration
  def change
    create_table :ques_answers do |t|
      t.text    :question
      t.text    :answer
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :event_id
      t.string  :status, :default => "pending"
      t.timestamps null: false
    end
  end
end
