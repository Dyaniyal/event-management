class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
    	t.text   :question
      t.string :option1
      t.string :option2
      t.string :option3
      t.string :option4
      t.string :option5
      t.string :option6
      t.string :status
      t.string :sequence
      t.references :event
      t.timestamps null: false
    end
  end
end
