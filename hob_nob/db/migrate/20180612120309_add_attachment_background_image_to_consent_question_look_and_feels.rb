class AddAttachmentBackgroundImageToConsentQuestionLookAndFeels < ActiveRecord::Migration
  def self.up
    change_table :consent_question_look_and_feels do |t|
      t.attachment :background_image
    end
  end

  def self.down
    remove_attachment :consent_question_look_and_feels, :background_image
  end
end
