class AddColumnTokenToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :token, :text
  end
end
