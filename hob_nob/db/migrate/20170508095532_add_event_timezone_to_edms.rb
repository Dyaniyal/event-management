class AddEventTimezoneToEdms < ActiveRecord::Migration
  def change
    add_column :edms, :event_timezone_offset, :string
    add_column :edms, :event_display_time_zone, :string
  end
end
