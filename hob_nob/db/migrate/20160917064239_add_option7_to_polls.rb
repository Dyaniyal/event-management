class AddOption7ToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :option7, :string
  end
end
