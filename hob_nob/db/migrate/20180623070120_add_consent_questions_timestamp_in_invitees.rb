class AddConsentQuestionsTimestampInInvitees < ActiveRecord::Migration
  def change
  	add_column :invitees, :consent_question_asnwered_time, :datetime
  end
end
