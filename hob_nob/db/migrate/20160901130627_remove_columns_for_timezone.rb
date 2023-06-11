class RemoveColumnsForTimezone < ActiveRecord::Migration
  def change
    remove_column :abouts, :created_at_with_event_timezone
    remove_column :abouts, :updated_at_with_event_timezone
    remove_column :agendas, :start_agenda_time_with_event_timezone
    remove_column :agendas, :end_agenda_time_with_event_timezone
    remove_column :analytics, :created_at_with_event_timezone
    remove_column :analytics, :updated_at_with_event_timezone
    remove_column :chats, :created_at_with_event_timezone
    remove_column :chats, :updated_at_with_event_timezone
    remove_column :conversations, :created_at_with_event_timezone
    remove_column :conversations, :updated_at_with_event_timezone
    remove_column :e_kits, :created_at_with_event_timezone
    remove_column :e_kits, :updated_at_with_event_timezone
    remove_column :faqs, :created_at_with_event_timezone
    remove_column :faqs, :updated_at_with_event_timezone
    remove_column :highlight_images, :created_at_with_event_timezone
    remove_column :highlight_images, :updated_at_with_event_timezone
    remove_column :polls, :poll_start_date_time_with_event_timezone
    remove_column :polls, :poll_end_date_time_with_event_timezone
    remove_column :qnas, :created_at_with_event_timezone
    remove_column :qnas, :updated_at_with_event_timezone
  end
end
