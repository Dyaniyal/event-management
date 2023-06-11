class AddSequenceToFeedback < ActiveRecord::Migration
  def change
  	add_column :feedbacks, :sequence, :integer
  end
end
