class AddMoreFiledsToDatabase < ActiveRecord::Migration
  def change
  	0..20.times do |i|
      add_column :invitee_data, "attr#{i+31}",:text
      add_column :invitee_structures, "attr#{i+31}",:text
  	end
  end
end
