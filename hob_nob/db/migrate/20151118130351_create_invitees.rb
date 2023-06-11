class CreateInvitees < ActiveRecord::Migration
  def change
    create_table :invitees do |t|
      t.string :event_name
      t.string :name_of_the_invitee
      t.string :email_address
      t.string :company_name
      t.string :invitee_status
      t.references :event, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
