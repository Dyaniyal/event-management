class Campaign < ActiveRecord::Base

  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am, :start_date_time, :end_date_time

  # belongs_to :event
  has_and_belongs_to_many :events
  has_many :edms, :dependent => :destroy
  validates :campaign_name, presence:{ :message => "This field is required." } 
  # before_validation :set_time
  after_save :set_total_mails_count
  after_destroy :remove_multi_lng_data
  scope :ordered, -> { order('created_at desc') }
  after_create :update_multi_lng_model_data 

  def remove_multi_lng_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) #if parent campaign is deleted then multi lng campaign event is also deleted.
    end
  end

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end 

  def set_time
    start_date = self.start_date_time rescue nil
    end_date = self.end_date_time rescue nil
    start_date = "#{start_date} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.start_time_am}" if start_date.present?
    end_date = "#{end_date} #{self.end_time_hour.gsub(':', "")  rescue nil}:#{self.end_time_minute.gsub(':', "")  rescue nil}:#{0} #{self.end_time_am}" if end_date.present?
      self.start_date = start_date.to_time rescue nil
      self.end_date = end_date.to_time rescue nil
  end

  def set_total_mails_count
    if (self.invitee_campaign.present? and self.invitee_campaign == "yes")
      edm_ids = self.edms.pluck(:id) if self.edms.present?
      total_mails = EdmMailSent.where(:event_id => self.event_id, :edm_id => edm_ids)
      self.update_column('total_mails_sent',total_mails.count) if total_mails.present?
    end
  end
end
