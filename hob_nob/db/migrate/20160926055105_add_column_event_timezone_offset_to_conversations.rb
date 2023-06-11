class AddColumnEventTimezoneOffsetToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :event_timezone_offset, :integer
  end
end
