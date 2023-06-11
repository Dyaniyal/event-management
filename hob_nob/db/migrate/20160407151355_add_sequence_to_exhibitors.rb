class AddSequenceToExhibitors < ActiveRecord::Migration
  def change
  	add_column :exhibitors, :sequence, :integer
  end
end
