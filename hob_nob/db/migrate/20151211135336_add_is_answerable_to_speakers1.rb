class AddIsAnswerableToSpeakers1 < ActiveRecord::Migration
  def change
  	add_column :speakers, :is_answerable, :string
  end
end
