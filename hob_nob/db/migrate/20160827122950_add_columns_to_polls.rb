class AddColumnsToPolls < ActiveRecord::Migration
  def change
  	add_column :polls, :option_type, :string
  	add_column :polls, :description, :boolean
  end
end
