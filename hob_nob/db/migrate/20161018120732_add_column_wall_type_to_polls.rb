class AddColumnWallTypeToPolls < ActiveRecord::Migration
  def change
  	add_column :polls, :wall_type, :string
  end
end
