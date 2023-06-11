class Map < ActiveRecord::Base
 	belongs_to :event

 	validates :map_id, :app_id, presence: { :message => "This field is required." }
end
