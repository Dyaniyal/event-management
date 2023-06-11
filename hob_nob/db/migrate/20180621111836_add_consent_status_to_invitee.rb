class AddConsentStatusToInvitee < ActiveRecord::Migration
  def change
  	add_column :invitees, :answered_consent_questions, :boolean, :default => false
  end
end
