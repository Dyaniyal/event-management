class AddEventIdToHighligth < ActiveRecord::Migration
  def change
  	add_column :highligth_images, :event_id, :integer
  end
end
