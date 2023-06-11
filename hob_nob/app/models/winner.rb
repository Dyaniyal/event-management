class Winner < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  belongs_to :award
  before_create :set_sequence_no
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_event_data
  before_save :update_event_id

  default_scope { order('sequence') }
  
  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove speaker of multilingual events if parent speaker delete.
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
      self.sequence = (Award.find_by_id(self.award_id).winners.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_event_id
    self.event_id = self.award.event_id rescue nil
  end

  def self.search(params, winners)
    name = params[:search][:keyword]
    winners = winners.where("name like (?) ", "%#{name}%") if name.present?
    winners
  end

end