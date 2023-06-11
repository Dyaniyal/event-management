class AddSequenceToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :sequence, :float
  end
end
