class AddIndexingToAwards < ActiveRecord::Migration
  def change
  	add_index :awards, [:title], :name => "index_title_on_awards"
  	add_index :awards, [:sequence], :name => "index_sequence_on_awards"
  end
end
