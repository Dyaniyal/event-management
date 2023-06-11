class ChangeAnswerDataTypeInUserPolls < ActiveRecord::Migration
  def change
  	change_column :user_polls, :answer, :text
  end
end
