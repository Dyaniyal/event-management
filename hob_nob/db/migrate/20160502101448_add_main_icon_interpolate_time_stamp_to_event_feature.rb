class AddMainIconInterpolateTimeStampToEventFeature < ActiveRecord::Migration
  def change
  	add_column :event_features, :main_icon_interpolate_time_stamp, :string
  end
end
