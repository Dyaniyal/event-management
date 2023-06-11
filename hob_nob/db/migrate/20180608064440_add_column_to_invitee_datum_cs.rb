class AddColumnToInviteeDatumCs < ActiveRecord::Migration
  def change
  	1.upto(10) do |i|
  	  add_column :invitee_data, :"consent_question_#{i}", :text
  	  add_column :invitee_data, :"consent_answer_#{i}", :text 
  	end
  end
end
