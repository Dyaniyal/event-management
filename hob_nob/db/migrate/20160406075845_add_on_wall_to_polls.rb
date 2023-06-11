class AddOnWallToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :on_wall, :string
  end
end
