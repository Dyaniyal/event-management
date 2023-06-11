class AddInterpolateTimeStampToEventFeature < ActiveRecord::Migration
  def change
  	add_column :event_features, :interpolate_time_stamp, :string
  end
end
