class AddConsentQuestionsAnsweredTimeToInviteeDatas < ActiveRecord::Migration
  def change
  	add_column :invitee_data, :consent_questions_answered_time, :datetime
  end
end
