class AddToPolls < ActiveRecord::Migration
  def change
  	add_column :polls, :show_poll_feature, :string
    add_column :polls, :group_ids, :text
  end
end
