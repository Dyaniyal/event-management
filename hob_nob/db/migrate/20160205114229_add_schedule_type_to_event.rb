class AddScheduleTypeToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :schedule_type, :string
  end
end
