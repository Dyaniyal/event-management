class Sponsor < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'

  belongs_to :event
  has_many :images, as: :imageable, :dependent => :destroy
  has_many :polls
  has_many :agendas
  has_many :e_kits
  attr_accessor :new_category,:image


  validate :image_dimensions 
  validate :check_category_in_present 
  validate :way_finder_location            
  has_attached_file :logo, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(SPONSOR_IMAGE_PATH)
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png"],:message => "please select valid format."
  validates :sponsor_type,:name, presence: { :message => "This field is required." }
  validates :email,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => "Sorry, this doesn't look like a valid email." }, :allow_blank => true
  validate :check_logo_is_present
  accepts_nested_attributes_for :images

  before_create :set_sequence_no
  before_save :add_new_category
  after_save :update_last_updated_model, :clear_cache#, :create_log_change_records_and_update_event_features
  before_save :rename_logo_file_name
  after_destroy :clear_cache
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
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove sponsor of multilingual events if parent sponsor delete.
    end  
  end 
  
  def update_multi_lng_sequence
    if self.parent_id.blank? and self.sequence_changed?
      SetMultLngSequence.set_seuqence(self)
    end  
  end  

  def create_log_change_records_and_update_event_features ##### quick fix for sponsor update issue andriod
    if self.event_id == 490
      LogChange.create(:changed_data => self.changed_attributes, :resourse_type => self.class.name, :resourse_id => self.id, :action => "destroy")
      event_features = self.event.event_features
      event_features.each{|ef| ef.update_attributes(:menu_icon_updated_at => Time.now, :main_icon_updated_at => Time.now)}
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def clear_cache
    Rails.cache.delete("sponsors_json_#{self.event.mobile_application_id}_published")
    Rails.cache.delete("sponsors_json_#{self.event.mobile_application_id}_approved_published")
  end

  def self.search(params,sponsors)
    sponsor_type = params[:search]
    sponsors = sponsors.where("sponsor_type like (?) ", "%#{sponsor_type}%") if sponsor_type.present?
    sponsors
  end

  def image_url(style=nil)
    if self.parent_id.present? and not self.logo.exists?
      parent = Sponsor.find(self.parent_id)
      style.present? ? parent.logo.url(style) : parent.logo.url 
    else
      style.present? ? self.logo.url(style) : self.logo.url 
    end
  end

  def add_new_category
    if self.sponsor_type == "New Category"
      self.sponsor_type = self.new_category
      self.save
    end
  end

  def check_logo_is_present
    if self.logo.blank?
      errors.add(:logo, "This field is required.")
    end  
  end 

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.event_id).sponsors.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  def way_finder_location
    if self.way_location.present? and self.way_location == "yes" and self.location.blank?
      errors.add(:location, "This field is required") 
    end
  end

  def image_dimensions
    if self.parent_id.blank?
      if self.logo_file_name_changed?  
        logo_dimension_height  = 300.0
        logo_dimension_width = 300.0
        dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path)
        if (dimensions.width != logo_dimension_width or dimensions.height != logo_dimension_height)
          errors.add(:logo, "Image size should be 300x300px only")
        else
          self.errors.delete(:logo)
        end
      end
    end
  end
  
  def rating
    Rating.where("ratable_type =?  and ratable_id =? and rating != 0","Sponsor",self.id).count
  end

  def check_category_in_present
    if self.sponsor_type.present? and self.sponsor_type == "New Category"
      errors.add(:new_category, "This field is required.") if self.new_category.blank?
    end
  end

  def rename_logo_file_name
    if (self.logo_updated_at_changed? and self.logo_file_name.present?)
      extension = File.extname(logo_file_name).downcase
      self.logo_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end
end
