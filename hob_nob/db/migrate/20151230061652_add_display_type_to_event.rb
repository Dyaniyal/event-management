class AddDisplayTypeToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :display_type, :string
  end
end
