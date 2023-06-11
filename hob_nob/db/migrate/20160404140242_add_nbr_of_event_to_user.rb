class AddNbrOfEventToUser < ActiveRecord::Migration
  def change
  	add_column :users, :no_of_event, :integer
  end
end
