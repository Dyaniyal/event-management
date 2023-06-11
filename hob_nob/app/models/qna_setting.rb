class QnaSetting < ActiveRecord::Base

  require 'set_mult_lng_data'
  validate :check_panel_email_present
  belongs_to :event
  validates :ask_a_question_to,presence: { :message => "This field is required." }
  validates_length_of :ask_a_question_to, :maximum => 20, :message => "Text must be less than 20 character"
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data 
  after_update :update_multi_lng_qna_setting
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end
  end

  def update_multi_lng_qna_setting
    if self.event.parent_id.nil?
      parent_event = self.event
      child_events = Event.where(:parent_id => parent_event.id)
      child_events.each do |child_event| 
        child_qna_setting = child_event.qna_settings.first rescue nil
        if not child_qna_setting.blank?
          child_qna_setting.display_qna_on_app = self.display_qna_on_app
          child_qna_setting.ask_a_question_to = self.ask_a_question_to
          child_qna_setting.description = self.description
          child_qna_setting.save
        end
      end
    end
  end

  def check_panel_email_present
  	if self.display_qna_on_app.present? and self.display_qna_on_app == "yes"
  		if self.event.panels.pluck(:speaker_email).include?('') or self.event.panels.pluck(:speaker_email).include?(nil)
  			errors.add(:display_qna_on_app, "Please enter email address for all experts to enable this feature")
  		end
  	end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end
end