class Feedback < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  attr_accessor :show_feedback_feature
  belongs_to :event
  belongs_to :feedback_form
  has_many :user_feedbacks
  has_many :favorites, as: :favoritable, :dependent => :destroy

  validates :question, presence: { :message => "This field is required." }
  validates :option_type,  presence: { :message => "This field is required." }, unless: Proc.new { |object| object.description == true }
  validates :option1, :option2, presence: { :message => "This field is required." }, if: Proc.new { |object| object.option_type == "Radio" || object.option_type == "Checkbox"}

  validate :validate_mandate_fields#, :feature_visibility
  before_create :set_sequence_no
  before_save :check_mandat_que_yes_no
  after_create :set_description_value#, :set_event_timezone
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data
  after_save :update_multi_lng_sequence 
  after_destroy :remove_multi_lng_event_data

  default_scope { order("sequence") }
  
  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove feedback of multilingual events if parent feedback delete.
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

  
  def check_mandat_que_yes_no
    self.mandat_response = "no" if mandat_question.present? and  mandat_question =="no"
  end  

  def validate_mandate_fields
    if self.mandat_question.blank?
      errors.add(:mandat_question, "This field is required.")
    end
    if self.description == true and self.option_type != "Textbox"
      if self.mandat_response.blank?
        errors.add(:mandat_response, "This field is required.")
      end
    end  
  end  


  def self.search(params,feedbacks)
    keyword = params[:search][:keyword]
    feedbacks = feedbacks.where("question like (?) ", "%#{keyword}%") if keyword.present?
    feedbacks
  end 

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.event_id).feedbacks.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  # def option_percentage(option_name='option1')
  #   percentage, count = 0, 0
  #   user_feedbacks = self.user_feedbacks
  #   total = self.user_feedbacks.count
  #   user_feedbacks.each do |ans|
  #     count = count + 1 if ans.answer.split(",").include? "option1"
  #     percentage = (count.to_f/total) * 100 rescue 0
  #   end
  #   return "#{percentage.to_i} %" 
  # end

  def set_description_value
    if self.option_type == "Textbox"
      self.update_columns(description:true,updated_at:Time.now)
      #self.description = true
      #self.save
    end
  end

  # def set_event_timezone
  #   event = self.event
  #   self.update_column("event_timezone", event.timezone)
  #   self.update_column("event_timezone_offset", event.timezone_offset)
  #   self.update_column("event_display_time_zone", event.display_time_zone)
  # end

  def created_at_with_event_timezone
    self.created_at + self.event.event_timezone_offset.to_i.seconds
  end

  def updated_at_with_event_timezone
    self.created_at + self.event.event_timezone_offset.to_i.seconds
  end

end