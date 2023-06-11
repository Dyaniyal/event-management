class TrackLinkUser < ActiveRecord::Base
	belongs_to :track_link

  def Timestamp
    self.updated_at.in_time_zone('Mumbai')
  end
end
