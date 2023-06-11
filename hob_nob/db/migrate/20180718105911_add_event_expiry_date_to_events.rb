class AddEventExpiryDateToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :expiry_date, :datetime
  end
end
