class AddRsvpMessageToEvent < ActiveRecord::Migration
  def change
  	 add_column :events, :rsvp_message, :text
  end
end
