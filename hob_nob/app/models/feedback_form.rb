class FeedbackForm < ActiveRecord::Base
	
	require 'set_mult_lng_data'
	require 'set_mult_lng_sequence'

	serialize :group_ids, Array
	belongs_to :event
	has_many :feedbacks, :dependent => :destroy
	has_many :user_feedbacks
	
	validates :title, presence: { :message => "This field is required." }

	validates :title, uniqueness: {scope: :event_id, :case_sensitive => false}

	after_save :update_last_updated_model
	before_create :set_sequence_no
	after_create :update_multi_lng_model_data 
	after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_event_data
	default_scope { order("sequence") }

  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove feedbackForm of multilingual events if parent feedbackForm delete.
    end  
  end

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end

  def update_multi_lng_sequence
    if self.parent_id.blank? and self.sequence_changed?
      SetMultLngSequence.set_seuqence(self)
    end  
  end    

	def set_sequence_no
    if self.parent_id.blank?
    	self.sequence = (Event.find(self.event_id).feedback_forms.pluck(:sequence).compact.max.to_i + 1)rescue nil
  	end
  end

	def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
  def feature_visibility
    errors.add(:group_ids, "This field is required.") if self.show_feedback_feature == "group"
  end
end