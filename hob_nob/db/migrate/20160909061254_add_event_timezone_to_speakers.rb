class AddEventTimezoneToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :event_timezone, :string
  end
end
