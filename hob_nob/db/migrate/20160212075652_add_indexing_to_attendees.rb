class AddIndexingToAttendees < ActiveRecord::Migration
  def change
  	add_index :attendees, [:attendee_name], :name => "index_attendee_name_on_attendees"
  	add_index :attendees, [:email_address], :name => "index_email_address_on_attendees"
  	add_index :attendees, [:phone_number], :name => "index_phone_number_on_attendees"
  end
end
