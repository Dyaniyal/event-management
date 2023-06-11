class AddMore5FieldsToUserRegistrations < ActiveRecord::Migration
  def change
	add_column :user_registrations, :field16, :text
	add_column :user_registrations, :field17, :text
	add_column :user_registrations, :field18, :text
	add_column :user_registrations, :field19, :text
	add_column :user_registrations, :field20, :text
  end

end
