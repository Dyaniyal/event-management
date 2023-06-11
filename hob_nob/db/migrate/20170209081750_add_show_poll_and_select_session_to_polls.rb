class AddShowPollAndSelectSessionToPolls < ActiveRecord::Migration
  def change
  	add_column :polls, :select_session, :string
  	add_column :polls, :show_poll_at, :string
  end
end
