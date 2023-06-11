class AddColumnToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :about, :string
  end
end
