class AddConsentQuestionAndAnswersToInvitees < ActiveRecord::Migration
  def change
  	1.upto(10) do |i|
  	  add_column :invitees, :"consent_question_#{i}", :text
  	  add_column :invitees, :"consent_answer_#{i}", :text 
    end  		
  end
end
