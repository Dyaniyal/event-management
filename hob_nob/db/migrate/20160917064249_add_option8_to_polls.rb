class AddOption8ToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :option8, :string
  end
end
