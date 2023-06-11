class CreateManageInviteeFields < ActiveRecord::Migration
  def change
    create_table :manage_invitee_fields do |t|
      t.integer :event_id
      t.string :name_of_the_invitee, default: "true"
      t.string :email, default: "true"
      t.string :company_name, default: "true"
      t.string :designation, default: "true"
      t.timestamps null: false
    end
  end
end
