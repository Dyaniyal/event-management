class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.text   :question
      t.string :option1
      t.string :option2
      t.string :option3
      t.string :option4
      t.string :option5
      t.string :option6
      t.references :event, index: true

      t.timestamps null: false
    end
  end
end
