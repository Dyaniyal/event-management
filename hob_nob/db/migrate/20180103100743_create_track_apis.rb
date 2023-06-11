class CreateTrackApis < ActiveRecord::Migration
  def change
    create_table :track_apis do |t|
      t.text :request_params
      t.string :key
      t.integer :event_id
      t.string :source
      t.datetime :previous_date_time

      t.timestamps null: false
    end
  end
end
