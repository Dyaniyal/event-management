class AddDisclaimerTextToRegistrations < ActiveRecord::Migration
  def change
  	add_column :registrations, :disclaimer_text, :text
  end
end
