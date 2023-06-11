class TrackApi < ActiveRecord::Base
	serialize :request_params, JSON

end
