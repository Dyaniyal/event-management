class Panel < ActiveRecord::Base

  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  belongs_to :event
  # validates :panel_id, presence: true
  has_many :received_questions, :class_name => 'Qna', :foreign_key => 'receiver_id'
  validate :check_speaker_is_present
  validates :speaker_email,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :allow_blank => true,
            :message => "Sorry, this doesn't look like a valid email." }
  before_create :set_sequence_no
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data 
  after_save :update_multi_lng_sequence
  
  default_scope { order("sequence") }

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

  def check_speaker_is_present
    if self.panel_id.present? and self.panel_id == 0
      errors.add(:speaker_name, "This field is required.") if self.name.blank?
      errors.add(:speaker_email, "This field is required.") if (self.speaker_email.blank? and (self.event.qna_settings.present? and  self.event.qna_settings.first.display_qna_on_app.present? and  self.event.qna_settings.first.display_qna_on_app == "yes"))
    else
      errors.add(:speaker_email, "This field is required.") if (self.speaker_email.blank? and (self.event.qna_settings.present? and  self.event.qna_settings.first.display_qna_on_app.present? and  self.event.qna_settings.first.display_qna_on_app == "yes"))
    end
  end

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Panel.where(:event_id => self.event_id).pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def hide_this_panel
    qnas = self.event.qnas if self.event.qnas.present?
    if qnas.present?
      hide_this_panel = qnas.pluck(:receiver_id).uniq.include?(self.id)
    end
  end
end