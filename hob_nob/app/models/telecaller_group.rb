class TelecallerGroup < ActiveRecord::Base
	belongs_to :event
	belongs_to :user
	serialize :assign_grouping, Array
	validates :assign_grouping, :target_assigned,:registration_target, presence:{ :message => "This field is required." }
	validate :set_groupings
	after_save :avoid_empty_group
	
	def set_groupings
		if self.assign_grouping.present?
			if self.assign_grouping.uniq.length == 1
				self.errors.add(:assign_grouping,'This field is required.')
			end
		end	
	end
	
	def avoid_empty_group
		groups = self.assign_grouping - ["0"]
		self.update_column('assign_grouping',groups)
	end	
end	
