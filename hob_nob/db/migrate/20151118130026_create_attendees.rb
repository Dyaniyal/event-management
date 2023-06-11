class CreateAttendees < ActiveRecord::Migration
  def change
    create_table :attendees do |t|
      t.string :attendee_name
      t.string :email_address
      t.string :company_name
      t.string :designation
      t.string :phone_number
      t.string :send_email
      t.references :event, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
