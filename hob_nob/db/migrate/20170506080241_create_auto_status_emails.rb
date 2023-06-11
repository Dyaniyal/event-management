class CreateAutoStatusEmails < ActiveRecord::Migration
  def change
    create_table :auto_status_emails do |t|
      t.integer :event_id
      t.text :auto_approved_email
      t.text :auto_reject_email

      t.timestamps null: false
    end
  end
end
