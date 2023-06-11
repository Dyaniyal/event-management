class AddColumnEventTimezoneToTables < ActiveRecord::Migration
  def change
    add_column :agendas, :event_timezone, :string
    add_column :attendees, :event_timezone, :string
    add_column :awards, :event_timezone, :string
    add_column :campaigns, :event_timezone, :string
    add_column :chats, :event_timezone, :string
    add_column :conversations, :event_timezone, :string
    add_column :event_features, :event_timezone, :string
    add_column :faqs, :event_timezone, :string
    add_column :feedbacks, :event_timezone, :string
    add_column :groupings, :event_timezone, :string
    add_column :invitee_notifications, :event_timezone, :string
    add_column :my_travels, :event_timezone, :string
    add_column :notes, :event_timezone, :string
    add_column :polls, :event_timezone, :string
    add_column :qnas, :event_timezone, :string
    add_column :quizzes, :event_timezone, :string
    add_column :edms, :event_timezone, :string    
  end
end
