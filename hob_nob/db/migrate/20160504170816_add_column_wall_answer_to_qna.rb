class AddColumnWallAnswerToQna < ActiveRecord::Migration
  def change
  	add_column :qnas, :wall_answer, :string
  end
end
