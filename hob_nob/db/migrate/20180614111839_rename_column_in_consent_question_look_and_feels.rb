class RenameColumnInConsentQuestionLookAndFeels < ActiveRecord::Migration
  def change
  	rename_column :consent_question_look_and_feels, :button_font, :button_font_color
  end
end
