class EventHighlightCount < ActiveRecord::Migration
  def change
  	add_column :events, :highlight_saved, :string
  end
end
