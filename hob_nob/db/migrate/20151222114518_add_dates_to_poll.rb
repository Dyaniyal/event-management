class AddDatesToPoll < ActiveRecord::Migration
  def change
  	add_column :polls, :poll_start_date, :date
  	add_column :polls, :poll_end_date, :date
  	add_column :polls, :status, :string
  end
end
