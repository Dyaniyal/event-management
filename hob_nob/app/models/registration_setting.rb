class RegistrationSetting < ActiveRecord::Base
  
  require 'set_mult_lng_data'

  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :start_date_time, :end_date_time
  belongs_to :event 

  before_validation :set_time
  validates :event_id, :registration, :on_mobile_app, :auto_approved,:auto_rejected,:target_attendees,:target_registration, presence: true
  # validates :login_url, :login_surl, :reg_url, :reg_surl, presence: true, :if :registration == 'hobnob'
  # validates :forget_pass_url, :forget_pass_surl, presence: true
  validate :check_external_regi_and_login_present,:check_start_and_end_date_are_present
  #validate :domain_name_present_for_auto_approved, :if => Proc.new{|p| p.auto_approved == "yes"}
  #validate :domain_name_present_for_auto_rejected, :if => Proc.new{|p| p.auto_rejected == "yes"}
  before_save :update_registation_login_url,:update_template_to_template_name
  after_save :update_registation_surl, :update_last_updated_model
  after_create :update_multi_lng_model_data 
  attr_accessor :template_name
  
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_registation_login_url
    if self.login == 'hobnob'
      event = self.event
      mobile_application = event.mobile_application
      self.login_url = "#{APP_URL}/admin/mobile_applications/#{mobile_application.id}/external_login?mobile_application_preview_code=#{mobile_application.preview_code}&mobile_application_code=#{mobile_application.submitted_code}"
      self.login_surl = "#{APP_URL}/admin/mobile_applications/#{mobile_application.id}/success"
    end
  end

  def update_registation_surl
    if self.registration == 'hobnob'
      event = self.event
      self.update_column(:reg_url ,"#{SAPP_URL}/admin/events/#{event.id}/user_registrations/new")
      self.update_column(:reg_surl ,"#{APP_URL}/admin/events/#{event.id}/success")
    end
  end
  def check_external_regi_and_login_present
    if self.registration == "external"
      errors.add(:external_reg_url, "This field is required.") if self.external_reg_url.blank?
      # errors.add(:external_reg_surl, "This field is required.") if self.external_reg_surl.blank?
    end
    if self.login == "external"
      errors.add(:external_login_url, "This field is required.") if self.external_login_url.blank?
      # errors.add(:external_login_surl, "This field is required.") if self.external_login_surl.blank?
    end
    if self.registration == "hobnob"
      errors.add(:template, "This field is required.") if self.template.blank?
    end
    if self.registration == "hobnob" and self.template.present? and self.template == "default"
      errors.add(:template_name, "This field is required.") if template_name.blank?
    end
  end

  def update_template_to_template_name
    if self.template.present? and self.template == "default" 
      self.template = template_name if template_name.present?
    end
  end

  def set_time
    start_date = self.start_date_time rescue nil
    end_date = self.end_date_time rescue nil
    start_date = "#{start_date} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.start_time_am}" if start_date.present?
    end_date = "#{end_date} #{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if end_date_time.present?
      self.start_date = start_date.to_datetime rescue nil
      self.end_date = end_date.to_datetime rescue nil
  end

  def check_start_and_end_date_are_present
    errors.add(:start_date, "This field is required.") if self.start_date_time.blank?
    errors.add(:end_date, "This field is required.") if self.end_date_time.blank?
  end

  def domain_name_present_for_auto_approved
    if (self.auto_approved.present? and self.auto_approved == "yes")
      errors.add(:auto_approved_domain_validation, "This field is required.") if self.auto_approved_domain_validation.blank?
    end
  end

  def domain_name_present_for_auto_rejected
    if (self.auto_rejected.present? and self.auto_rejected == "yes")
      errors.add(:auto_rejected_domain_validation, "This field is required.") if self.auto_rejected_domain_validation.blank?
    end
  end
end