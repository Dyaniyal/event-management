class AddColumnRsvpToEvent < ActiveRecord::Migration
  def change
    add_column :events, :rsvp, :string, :default => "No"
  end
end