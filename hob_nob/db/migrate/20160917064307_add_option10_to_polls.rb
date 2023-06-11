class AddOption10ToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :option10, :string
  end
end
