class Poll < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  serialize :group_ids, Array
  include ApplicationHelper
  attr_accessor :start_time_hour, :start_time_minute ,:start_time_am, :end_time_hour, :end_time_minute ,:end_time_am

  belongs_to :event
  belongs_to :sponsor
  has_many :user_polls, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  validates :option_type,  presence: { :message => "This field is required." }, unless: Proc.new { |object| object.description == true }
  validates :question, presence: { :message => "This field is required." }
  validates :option1, :option2, presence: { :message => "This field is required." }, if: Proc.new { |object| object.option_type == "Radio" || object.option_type == "Checkbox"}
  # validate :feature_visibility
  before_save :set_time
  after_save :push_notification, :check_push_to_wall_status, :update_last_updated_model
  before_create :set_sequence_no
  after_create :set_status_as_per_auto_approve, :set_event_timezone
  after_create :update_multi_lng_model_data 
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_event_data
  # POLL_OPTION_TYPE = ['Wall1', 'Wall2', 'Wall3', 'Wall4', 'Wall5']

  default_scope { order("sequence") }

  include AASM
  aasm :column => :status do  # defaults to aasm_state
    state :activate, :initial => true
    state :deactivate
    
    event :activate do
      transitions :from => [:deactivate], :to => [:activate]
    end 
    event :deactivate do
      transitions :from => [:activate], :to => [:deactivate]
    end
  end

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
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def set_status
    if self.status.blank?
      self.status = "activate"
      self.save
    end
  end

  def self.search(params,polls)
    keyword = params[:search][:keyword]
     polls = polls.where("question like (?) ", "%#{keyword}%") if keyword.present?
  end   

  def push_notification
    if self.status == 'approved' and self.status_changed?
      client = self.event.client
      licensee_user = User.find(client.licensee_id) rescue nil
      if licensee_user.present?
        users = licensee_user.get_licensee_users
        users.each do |u|
          u.push_notifications("New polls for you", 'Poll', self.id)
        end
      end
    end
  end
  
  def check_push_to_wall_status
    if self.status == "deactivate"
      self.update_column(:on_wall, "no")
    end
  end
  
  def option_percentage
    Rails.cache.fetch("poll_option_percentage#{self.id}") { option_percentage! }
  end

  def option_percentage!
    data = {}
    option1=option2=option3=option4=option5=option6=option7=option8=option9=option10=0
    data["total"] = self.user_polls.count
    self.user_polls.each do |user_poll|
      if is_number? user_poll.answer
        option1 = user_poll.answer.to_i == 1 ? option1 + 1 : option1 rescue option1
        option2 = user_poll.answer.to_i == 2 ? option2 + 1 : option2 rescue option2
        option3 = user_poll.answer.to_i == 3 ? option3 + 1 : option3 rescue option3
        option4 = user_poll.answer.to_i == 4 ? option4 + 1 : option4 rescue option4
        option5 = user_poll.answer.to_i == 5 ? option5 + 1 : option5 rescue option5
      else  
        option1 = user_poll.answer.downcase.include?("option1") ? option1 + 1 : option1 rescue option1
        option2 = user_poll.answer.downcase.include?("option2") ? option2 + 1 : option2 rescue option2
        option3 = user_poll.answer.downcase.include?("option3") ? option3 + 1 : option3 rescue option3
        option4 = user_poll.answer.downcase.include?("option4") ? option4 + 1 : option4 rescue option4
        option5 = user_poll.answer.downcase.include?("option5") ? option5 + 1 : option5 rescue option5
        option6 = user_poll.answer.downcase.include?("option6") ? option6 + 1 : option6 rescue option6
        option7 = user_poll.answer.downcase.include?("option7") ? option7 + 1 : option7 rescue option7
        option8 = user_poll.answer.downcase.include?("option8") ? option8 + 1 : option8 rescue option8
        option9 = user_poll.answer.downcase.include?("option9") ? option9 + 1 : option9 rescue option9
        option10 = user_poll.answer.downcase.include?("option010") ? option10 + 1 : option10 rescue option10        
      end  
    end
    data["option1"] = option1 rescue nil
    data["option2"] = option2 rescue nil
    data["option3"] = option3 rescue nil 
    data["option4"] = option4 rescue nil
    data["option5"] = option5 rescue nil
    data["option6"] = option6 rescue nil
    data["option7"] = option7 rescue nil
    data["option8"] = option8 rescue nil
    data["option9"] = option9 rescue nil
    data["option10"] = option10 rescue nil
    data
  end

  def option10
    self.option010
  end

  def change_status(poll)
    if poll == "activate"
      self.activate!
    elsif poll == "deactivate"
      self.update_column(:wall_type, nil)
      self.deactivate!
    end
  end

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.event_id).polls.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  def set_time
    start_date = self.poll_start_date_time.nil? ? Time.now : self.poll_start_date_time
    end_date = self.poll_end_date_time.nil? ? Time.now : self.poll_end_date_time
    start_date_time = "#{start_date.strftime('%d/%m/%Y')} #{self.start_time_hour.gsub(':', "") rescue nil}:#{self.start_time_minute.gsub(':', "") rescue nil}:#{0} #{self.start_time_am}"
    end_date_time = "#{end_date.strftime('%d/%m/%Y')} #{self.end_time_hour.gsub(':', "") rescue nil}:#{self.end_time_minute.gsub(':', "") rescue nil}:#{0} #{self.end_time_am}"
    self.poll_start_date_time = start_date_time.to_time rescue nil
    self.poll_end_date_time = end_date_time.to_time rescue nil
  end

  def time_format
    if (self.start_time_hour.blank? or self.start_time_minute.blank? or self.start_time_am.blank?)
      errors.add(:start_time_hour, "can't be blank")
    end

    if (self.start_time_hour.blank? or self.start_time_minute.blank? or self.start_time_am.blank?)
      errors.add(:start_time_hour, "can't be blank")
    end
  end

  def set_status_as_per_auto_approve
    if Event.find(self.event_id).poll_auto_approve == "true"
      self.update_column(:status, "activate") 
    elsif Event.find(self.event_id).poll_auto_approve == "false"
      self.update_column(:status, "deactivate")
    end
  end

  def set_dates_with_event_timezone
    event = self.event
    self.update_column("poll_start_date_time_with_event_timezone", self.poll_start_date_time.to_datetime.in_time_zone(event.timezone))
    self.update_column("poll_end_date_time_with_event_timezone", self.poll_end_date_time.to_datetime.in_time_zone(event.timezone))    
  end

  # def poll_start_date_time_with_event_timezone
  #   self.poll_start_date_time.in_time_zone(self.event.timezone)
  # end

  # def poll_end_date_time_with_event_timezone
  #   self.poll_end_date_time.in_time_zone(event.timezone)
  # end
  
  def self.set_auto_approve(value,event)
    event.update_column(:poll_auto_approve, value)
  end

  def update_event_timezone
    event = self.event
    self.update_column("event_timezone", event.timezone)
    self.event_timezone
  end

  def set_event_timezone
    self.update_column(:event_timezone, self.event.timezone)
  end

  def feature_visibility
    errors.add(:group_ids, "This field is required.") if self.show_poll_feature == "group"
  end

end
