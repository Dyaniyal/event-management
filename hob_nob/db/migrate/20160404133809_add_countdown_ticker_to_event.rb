class AddCountdownTickerToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :countdown_ticker, :string, :default => "No"
  end
end
