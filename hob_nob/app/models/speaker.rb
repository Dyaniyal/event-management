class Speaker < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  serialize :group_ids, Array
  
  belongs_to :event
  has_many :ratings, as: :ratable, :dependent => :destroy
  has_many :agendas

  #has_many :received_questions, :class_name => 'Qna', :foreign_key => 'receiver_id'
  has_many :panels, as: :panel, :dependent => :destroy
  has_many :favorites, as: :favoritable, :dependent => :destroy
  has_many :analytics, :class_name => 'Analytic', :foreign_key => :viewable_id
  has_attached_file :profile_pic, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(SPEAKER_IMAGE_PATH)

  validates_attachment_content_type :profile_pic, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  validates :first_name, :last_name,:designation, presence: { :message => "This field is required." }
  
  validates :email_address,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => "Sorry, this doesn't look like a valid email." }, :allow_blank => true
  # validates :phone_no,
  #           :numericality => true,
  #           :length => { :minimum => 10, :maximum => 12,
  #           :message=> "Please enter a valid 10 digit number" }, :allow_blank => true
  validates :event_id,:rating_status ,:presence => true
  #validates :sequence, uniqueness: {scope: :event_id}#, presence: true
  validate :image_dimensions#, :feature_visibility
  before_create :set_sequence_no
  # after_create :set_event_timezone
  before_save :set_full_name
  after_save :update_last_updated_model, :clear_cache
  after_update :update_agenda_speaker_name
  after_destroy :empty_agenda_speaker_name_and_id, :clear_cache
  before_destroy :delete_speaker_name_from_agenda
  before_save :rename_profile_pic_file_name
  after_create :update_multi_lng_model_data 
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_event_data
  default_scope { order("sequence") }  
 
  def update_multi_lng_sequence
    if self.parent_id.blank? and self.sequence_changed?
      SetMultLngSequence.set_seuqence(self)
    end  
  end

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
  
  def delete_speaker_name_from_agenda
    agenda_ids = self.all_agenda_ids.to_s.split(', ')
    agenda_ids = agenda_ids.reject { |e| e.to_s.empty? }
    agenda_ids.each do |agenda_id|
      agenda = Agenda.find(agenda_id) rescue ''
      if agenda.present?
        agenda_speaker_names = agenda.all_speaker_names.to_s.split(", ")
        agenda.update_column("speaker_ids", (agenda.speaker_ids.to_s.split(", ") - [self.id.to_s]).uniq.join(", "))
        agenda.update_column("all_speaker_names", (agenda_speaker_names - [self.speaker_name]).uniq.join(", "))
        agenda.update_columns(updated_at: Time.now)
        agenda.update_last_updated_model
      end
    end if agenda_ids.present?
  end

  def clear_cache
    Rails.cache.delete("speakers_json_#{self.event.mobile_application_id}_published")
    Rails.cache.delete("speakers_json_#{self.event.mobile_application_id}_approved_published")
  end

  def update_agenda_speaker_name
    if self.speaker_name_changed?
      # agendas = Agenda.where(event_id:self.event_id,speaker_id:self.id)
      agendas = Agenda.where(:id => self.all_agenda_ids.to_s.split(", "))
      if agendas.present?
        agendas.each do |agenda|
          agenda_speaker_names = agenda.all_speaker_names.to_s.split(", ")
          agenda.update_column("all_speaker_names", (agenda_speaker_names - [self.speaker_name_was] + [self.speaker_name]).uniq.join(", "))
          agenda.update_columns(updated_at: Time.now)
          agenda.update_last_updated_model
        end  
      end
    end  
  end

  def empty_agenda_speaker_name_and_id
    agendas = Agenda.where(event_id:self.event_id,speaker_id:self.id)
    if agendas.present?
      agendas.each do |agenda|
        agenda.update_columns(speaker_id: "",speaker_name: "",updated_at: Time.now) 
        agenda.update_last_updated_model
      end  
    end
  end  

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def self.search(params, speakers)
    speaker_name,email_address,designation,company_name = params[:search][:name],params[:search][:email_address],params[:search][:designation],params[:search][:company_name] if params[:adv_search].present?
    basic = params[:search_keyword]
    speakers = speakers.where("speaker_name like ?", "%#{speaker_name}%") if   speaker_name.present?
    speakers = speakers.where("email_address like ?", "%#{email_address}%") if  email_address.present?
    speakers = speakers.where(designation: designation) if designation.present?
    speakers = speakers.where(company:  company_name) if company_name.present?    
    speakers = speakers.where("speaker_name like ? or company like ? or designation like ?", "%#{basic}%","%#{basic}%","%#{basic}%") if basic.present?
    speakers
  end

  def profile_picture(style = nil)
    if self.parent_id.present? and not self.profile_pic.exists?
      parent = Speaker.find(self.parent_id)
      style.present? ? parent.profile_pic.url(style) : parent.profile_pic.url 
    else
      style.present? ? self.profile_pic.url(style) : self.profile_pic.url 
    end
  end
  
  def set_full_name
    self.speaker_name = self.first_name + " " + self.last_name
  end

  def calculate_rating
    self.ratings.pluck(:rating).sum / self.ratings.count rescue 0
  end

  def self.get_speaker(id)
    Speaker.find_by_id(id)
  end

  def ana
    Task.where("owner_id = ? OR assigneed_id = ?", self.id, self.id)
  end

  def is_rated
    # self.ratings.present? ? true : false
    (self.ratings_count_cache.to_i > 0)
  end 

  def profile_pic_url(style=:large)
    if self.parent_id.present? and not self.profile_pic.exists?
      parent = Speaker.find(self.parent_id)
      style.present? ? parent.profile_pic.url(style) : parent.profile_pic.url 
    else
      style.present? ? self.profile_pic.url(style) : self.profile_pic.url
    end
  end

  def image_dimensions
    if self.profile_pic_file_name_changed? and self.parent_id.blank?
      speaker_dimension_height  = 400.0
      speaker_dimension_width = 400.0
      dimensions = Paperclip::Geometry.from_file(profile_pic.queued_for_write[:original].path)
      if (dimensions.width != speaker_dimension_width or dimensions.height != speaker_dimension_height)
        errors.add(:profile_pic, "Image size should be 400x400px only")
      end
    end
  end

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.event_id).speakers.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  # def set_event_timezone
  #   event = self.event
  #   self.update_column("event_timezone", event.timezone)
  #   self.update_column("event_timezone_offset", event.timezone_offset)
  #   self.update_column("event_display_time_zone", event.display_time_zone)
  # end

  def rename_profile_pic_file_name
    # self.profile_pic = URI.parse(Speaker.find(self.parent_id).profile_pic.url).open if self.event.copy_event == "yes"
    self.profile_pic = Speaker.find(self.parent_id).profile_pic if self.event.copy_event == "yes"
    if (self.profile_pic_updated_at_changed? and self.profile_pic_file_name.present?)
      extension = File.extname(profile_pic_file_name).downcase
      self.profile_pic_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end

  def facebook_link
    self.facebook_id rescue ""
  end

  def google_link
    self.google_id rescue ""
  end
  
  def linkedin_link
    self.linkedin_id rescue ""
  end

  def twitter_link
    self.twitter_id rescue ""
  end

  def feature_visibility
    errors.add(:group_ids, "This field is required.") if self.show_speaker_feature == "group"
  end
end

