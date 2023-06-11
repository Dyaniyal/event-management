class AddColumnsToUserRegistrations < ActiveRecord::Migration
  def change
  	add_column :user_registrations, :remark1, :text
  	add_column :user_registrations, :remark2, :text
  	add_column :user_registrations, :remark3, :text
  	add_column :user_registrations, :remark4, :text
  	add_column :user_registrations, :remark5, :text
  end
end
