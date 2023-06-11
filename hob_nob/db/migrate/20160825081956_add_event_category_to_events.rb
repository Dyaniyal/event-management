class AddEventCategoryToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_category, :string
  end
end
