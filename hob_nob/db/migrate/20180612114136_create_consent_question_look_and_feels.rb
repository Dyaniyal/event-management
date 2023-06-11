class CreateConsentQuestionLookAndFeels < ActiveRecord::Migration
  def change
    create_table :consent_question_look_and_feels do |t|
      t.integer :mobile_application_id
      t.text :heading_text
      t.text :button_text
      t.string :button_color
      t.string :button_font
      t.string :background_color
      
      t.timestamps null: false
    end
  end
end
