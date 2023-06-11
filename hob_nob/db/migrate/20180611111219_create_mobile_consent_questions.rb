class CreateMobileConsentQuestions < ActiveRecord::Migration
  def change
    create_table :mobile_consent_questions do |t|
      t.integer :mobile_application_id
		  t.string :question
		  t.string :answer_type
      t.string :answer
      1.upto(10) do |i|
  	    t.text :"option_#{i}"
      end
      t.timestamps null: false
    end
  end
end
