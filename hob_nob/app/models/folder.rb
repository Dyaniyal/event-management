class Folder < ActiveRecord::Base
	belongs_to :event
	has_many :images, :dependent => :destroy
  before_create :set_sequence_no
  after_create :update_multi_lng_model_data
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_model_data
  
  default_scope { order('sequence') }
  
	def set_sequence_no
    self.sequence = (Event.find(self.event_id).folders.pluck(:sequence).compact.max.to_i + 1) rescue nil
  end

  def remove_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) #if agenda parent event deleted then multilngdata also deleted.
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
  
end
