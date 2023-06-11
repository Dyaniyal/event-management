class Faq < ActiveRecord::Base
      
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  belongs_to :user
  belongs_to :event
  has_many :favorites, as: :favoritable, :dependent => :destroy
  #attr_accessor :new_category, :faq_setting
  #validate :check_category_in_present
  #validates :faq_type, :presence => true, :if => Proc.new{|p| p.faq_setting}
  #before_save :add_new_category
  validates :question, :answer,  presence: { :message => "This field is required." }
  #validates :sequence, uniqueness: {scope: :event_id}#, presence: true
  before_create :set_sequence_no
  # after_create :set_event_timezone
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data 
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_event_data
  default_scope { order("sequence") } 

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end

  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove speaker of multilingual events if parent speaker delete.
    end  
  end 
   
  def update_multi_lng_sequence
    if self.parent_id.blank? and self.sequence_changed?
      SetMultLngSequence.set_seuqence(self)
    end  
  end       

  def self.search(params,faqs)
    keyword = params[:search][:keyword]
      faqs = faqs.where("question like ? or answer like ? or sequence like (?)", "%#{keyword}%","%#{keyword}%","%#{keyword}%")if keyword.present?
      faqs
  end 
  
  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.event_id).faqs.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  # def set_event_timezone
  #   event = self.event
  #   self.update_column("event_timezone", event.timezone)
  #   self.update_column("event_timezone_offset", event.timezone_offset)
  #   self.update_column("event_display_time_zone", event.display_time_zone)
  # end
  #COMMENTED FOR FAQ SETTING
  # def add_new_category
  #   if self.faq_type == "New Category"
  #     self.faq_type = self.new_category
  #     self.save
  #   end
  # end

  # def check_category_in_present
  #   if self.faq_type.present? and self.faq_type == "New Category"
  #     errors.add(:new_category, "This field is required.") if self.new_category.blank?
  #   end
  # end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

end
