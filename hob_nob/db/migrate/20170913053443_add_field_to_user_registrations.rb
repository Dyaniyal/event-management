class AddFieldToUserRegistrations < ActiveRecord::Migration
  def change
  	0..10.times do |i|
      add_column :user_registrations, "field#{i+21}",:text
  	end
  end
end
