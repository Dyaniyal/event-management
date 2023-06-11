class AddTimezoneOffsetToEvents < ActiveRecord::Migration
  def change
    add_column :events, :timezone_offset, :integer
  end
end
