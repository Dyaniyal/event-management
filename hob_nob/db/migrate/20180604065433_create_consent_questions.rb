class CreateConsentQuestions < ActiveRecord::Migration
  def change
    create_table :consent_questions do |t|
      t.integer :event_id
	    t.string :question
	    t.string :answer_type
	    t.string :answer
      t.timestamps null: false
    end
  end
end
