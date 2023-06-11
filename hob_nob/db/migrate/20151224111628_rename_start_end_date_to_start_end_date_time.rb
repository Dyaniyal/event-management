class RenameStartEndDateToStartEndDateTime < ActiveRecord::Migration
  def change
  	rename_column :polls, :poll_start_date, :poll_start_date_time
  	rename_column :polls, :poll_end_date, :poll_end_date_time
  	change_column :polls, :poll_start_date_time, :datetime
  	change_column :polls, :poll_end_date_time, :datetime
  end
end
