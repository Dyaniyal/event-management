class AddMore5FieldsToRegistrations < ActiveRecord::Migration
  def change
  	add_column :registrations, :field16, :text
  	add_column :registrations, :field17, :text
  	add_column :registrations, :field18, :text
  	add_column :registrations, :field19, :text
  	add_column :registrations, :field20, :text
  end
end
