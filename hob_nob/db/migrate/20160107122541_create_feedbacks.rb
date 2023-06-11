class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.belongs_to :event
      t.string :question
      t.string :option1
      t.string :option2
      t.string :option3
      t.string :option4
      t.string :option5
      t.string :option_type
      t.boolean :destription
      t.timestamps null: false
    end
  end
end
