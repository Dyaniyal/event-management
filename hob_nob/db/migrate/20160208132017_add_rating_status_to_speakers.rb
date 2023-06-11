class AddRatingStatusToSpeakers < ActiveRecord::Migration
  def change
    add_column :speakers, :rating_status, :string, :default => "active"
  end
end
