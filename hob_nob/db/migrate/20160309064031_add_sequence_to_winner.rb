class AddSequenceToWinner < ActiveRecord::Migration
  def change
  	add_column :winners, :sequence, :integer
  end
end
