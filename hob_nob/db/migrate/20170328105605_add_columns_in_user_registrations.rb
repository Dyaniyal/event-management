class AddColumnsInUserRegistrations < ActiveRecord::Migration
  def change
  	add_column :user_registrations, :rfid, :string
  	add_column :user_registrations, :event_kit, :boolean, :default => false
  	add_column :user_registrations, :gift, :boolean, :default => false
  	add_column :user_registrations, :comment, :text
  	add_column :user_registrations, :walk_in_registration, :boolean, :default => false
  	add_column :user_registrations, :registration_type, :string
  end
end