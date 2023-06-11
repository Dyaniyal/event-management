class AddColumnsForEventTimezoneOffsetToTables < ActiveRecord::Migration
  def change
    add_column :agendas, :event_timezone_offset, :string
    add_column :agendas, :event_display_time_zone, :string
    add_column :attendees, :event_timezone_offset, :string
    add_column :attendees, :event_display_time_zone, :string
    add_column :awards, :event_timezone_offset, :string
    add_column :awards, :event_display_time_zone, :string
    add_column :chats, :event_timezone_offset, :string
    add_column :chats, :event_display_time_zone, :string
    add_column :conversations, :event_timezone_offset, :string
    add_column :conversations, :event_display_time_zone, :string
    add_column :event_features, :event_timezone_offset, :string
    add_column :event_features, :event_display_time_zone, :string
    add_column :faqs, :event_timezone_offset, :string
    add_column :faqs, :event_display_time_zone, :string
    add_column :feedbacks, :event_timezone_offset, :string
    add_column :feedbacks, :event_display_time_zone, :string
    add_column :groupings, :event_timezone_offset, :string
    add_column :groupings, :event_display_time_zone, :string
    add_column :my_travels, :event_timezone_offset, :string
    add_column :my_travels, :event_display_time_zone, :string
    add_column :polls, :event_timezone_offset, :string
    add_column :polls, :event_display_time_zone, :string
    add_column :qnas, :event_timezone_offset, :string
    add_column :qnas, :event_display_time_zone, :string
    add_column :quizzes, :event_timezone_offset, :string
    add_column :quizzes, :event_display_time_zone, :string
    add_column :notifications, :event_timezone_offset, :string
    add_column :notifications, :event_display_time_zone, :string
    add_column :invitees, :event_timezone_offset, :string
    add_column :invitees, :event_display_time_zone, :string
    add_column :speakers, :event_timezone_offset, :string
    add_column :speakers, :event_display_time_zone, :string
  end
end
