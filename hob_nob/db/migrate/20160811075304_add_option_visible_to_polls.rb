class AddOptionVisibleToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :option_visible, :string, :default => "yes"
  end
end
