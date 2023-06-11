class AddAttrsToInviteeDatas < ActiveRecord::Migration
  def change
  	0..10.times do |i|
      add_column :invitee_data, "attr#{i+21}",:text
  	end
  end
end
