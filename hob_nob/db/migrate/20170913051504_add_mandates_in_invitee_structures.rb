class AddMandatesInInviteeStructures < ActiveRecord::Migration
  def change
  	0..10.times do |i|
      add_column :invitee_structures, "mandate_attr#{i+21}",:text
  	end
  end
end
