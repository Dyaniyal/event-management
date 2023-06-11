class Award < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  belongs_to :event
  has_many :winners, :dependent => :destroy

  validates :title,presence: { :message => "This field is required." }
  
  before_create :set_sequence_no
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data 
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_model_data
  default_scope { order("sequence") }
  
  def remove_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) #to remove multilingual data if parent data is deleted.
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

  def self.search(params, awards)
    keyword = params[:search][:keyword]
    awards = awards.where("title like ?", "%#{keyword}%") if keyword.present?
    awards
  end

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.event_id).awards.pluck(:sequence).compact.max.to_i + 1) rescue nil
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
end