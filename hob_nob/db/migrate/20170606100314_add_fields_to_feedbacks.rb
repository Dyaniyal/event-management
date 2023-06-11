class AddFieldsToFeedbacks < ActiveRecord::Migration
  def change
  	add_column :feedbacks, :mandat_question, :string
  	add_column :feedbacks, :mandat_response, :string
  end
end

