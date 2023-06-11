class AddGoogleIdToSpeakers < ActiveRecord::Migration
  def change
  	add_column :speakers, :google_id, :string
  end
end
