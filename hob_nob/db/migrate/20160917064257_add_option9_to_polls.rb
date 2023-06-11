class AddOption9ToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :option9, :string
  end
end
