class AddEmailFieldToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :email_field, :string
  end
end
