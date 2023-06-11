class AddEventIdToWinners < ActiveRecord::Migration
  def change
    add_column :winners, :event_id, :integer
  end
end
