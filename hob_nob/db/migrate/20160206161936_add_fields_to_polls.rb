class AddFieldsToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :poll_start_time, :datetime
    add_column :polls, :poll_end_time, :datetime
  end
end
