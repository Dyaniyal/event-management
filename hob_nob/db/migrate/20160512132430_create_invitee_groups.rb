class CreateInviteeGroups < ActiveRecord::Migration
  def change
    create_table :invitee_groups do |t|
    	t.string :name
    	t.integer :event_id
    	t.integer :group_id
    	t.text :invitee_ids
      t.timestamps null: false
    end
  end
end
