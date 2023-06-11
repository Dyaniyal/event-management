class CreateSmtpSettings < ActiveRecord::Migration
  def change
    create_table :smtp_settings do |t|
      t.integer :user_id
      t.string :username
      t.string :password
      t.string :domain
      t.string :address
      t.string :from_email

      t.timestamps null: false
    end
  end
end
