class AddEventIdToEdms < ActiveRecord::Migration
  def change
  	add_column :edms, :event_id, :integer
  end
end
