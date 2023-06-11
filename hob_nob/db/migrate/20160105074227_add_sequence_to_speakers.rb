class AddSequenceToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :sequence, :float
  end
end
