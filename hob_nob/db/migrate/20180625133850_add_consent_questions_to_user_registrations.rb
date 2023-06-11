class AddConsentQuestionsToUserRegistrations < ActiveRecord::Migration
  def change
  	1.upto(10) do |i|
       add_column :user_registrations, :"consent_question_#{i}", :text
       add_column :user_registrations, :"consent_answer_#{i}", :text
  	end
    add_column :user_registrations, :date_timestamp, :datetime
  end
end
