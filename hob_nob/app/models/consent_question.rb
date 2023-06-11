class ConsentQuestion < ActiveRecord::Base
	belongs_to :event
	validates :answer_type, :presence => {:message => "This field is required."}
	validate :options
	
	def options
    if self.answer_type.present? 
      errors.add(:option_1, "This field is required.") if self.option_1.blank?
      errors.add(:option_2, "This field is required.") if self.option_2.blank?
    end
	end
end
