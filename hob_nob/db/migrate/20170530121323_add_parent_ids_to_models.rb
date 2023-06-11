class AddParentIdsToModels < ActiveRecord::Migration
  def change
  	add_column :my_profiles, :parent_id, :integer
  	add_column :notifications, :parent_id, :integer
  	add_column :poll_walls, :parent_id, :integer
  	add_column :conversation_walls, :parent_id, :integer
  	add_column :qna_walls, :parent_id, :integer
  	add_column :quiz_walls, :parent_id, :integer
  	add_column :e_kits, :parent_id, :integer
  	add_column :conversations, :parent_id, :integer
  	add_column :qnas, :parent_id, :integer
  	add_column :polls, :parent_id, :integer
  	add_column :quizzes, :parent_id, :integer
  	add_column :feedback_forms, :parent_id, :integer
    add_column :manage_invitee_fields, :parent_id, :integer
    add_column :invitee_data, :parent_id, :integer
  end
end
