class AddEventIdToUserTables < ActiveRecord::Migration
  def change
    ["user_polls", "user_quizzes","user_feedbacks"].each do |table|
      add_column :"#{table}", :event_id, :integer
      add_column :"#{table}", :invitee_id, :integer
    end
  end
end
