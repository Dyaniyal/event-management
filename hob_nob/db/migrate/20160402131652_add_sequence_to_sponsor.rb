class AddSequenceToSponsor < ActiveRecord::Migration
  def change
  	add_column :sponsors, :sequence, :integer
  end
end
