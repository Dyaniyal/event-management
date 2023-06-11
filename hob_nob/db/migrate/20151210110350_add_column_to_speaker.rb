class AddColumnToSpeaker < ActiveRecord::Migration
  def change
  	add_column :speakers, :company, :string
  end
end
