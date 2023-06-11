class AddSequenceToAward < ActiveRecord::Migration
  def change
  	add_column :awards, :sequence, :integer
  end
end
