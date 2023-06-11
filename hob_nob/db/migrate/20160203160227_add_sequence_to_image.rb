class AddSequenceToImage < ActiveRecord::Migration
  def change
  	add_column :images, :sequence, :integer
  end
end
