class Exhibitor < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'
  
  belongs_to :event
  has_attached_file :image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80",
                                         :thumb => "-strip -quality 80"}
                                         }.merge(EXHIBITOR_IMAGE_PATH)
  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png"],:message => "please select valid format."
  validates :name,:image, presence:{ :message => "This field is required." }
  validates :email,
            :format => {
            :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
            :message => "Sorry, this doesn't look like a valid email." }, :allow_blank => true
  validate :image_dimensions
  before_create :set_sequence_no
  after_save :update_last_updated_model, :clear_cache
  after_destroy :clear_cache
  before_save :rename_image_name
  after_create :update_multi_lng_model_data 
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_event_data

  default_scope { order('sequence') }

  def remove_multi_lng_event_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) # e.g remove exhibitor of multilingual events if parent exhibitor delete.
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

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def clear_cache
    Rails.cache.delete("exhibitors_json_#{self.event.mobile_application_id}_published")
    Rails.cache.delete("exhibitors_json_#{self.event.mobile_application_id}_approved_published")
  end

  def image_url(style=:small)
    if self.parent_id.present? and not self.image.exists?
      parent = Exhibitor.find(self.parent_id)
      style.present? ? parent.image.url(style) : parent.image.url
    else
      style.present? ? self.image.url(style) : self.image.url
    end
  end

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.event_id).exhibitors.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  def image_dimensions
    if self.image_file_name_changed? and self.parent_id.blank?
      image_dimension_height  = 300.0
      image_dimension_width = 300.0
      dimensions = Paperclip::Geometry.from_file(image.queued_for_write[:original].path)
      if (dimensions.width != image_dimension_width or dimensions.height != image_dimension_height)
        errors.add(:image, "Image size should be 300x300px only")
      else
        self.errors.delete(:image)
      end
    end
  end

  def rename_image_name
    if (self.image_updated_at_changed? and self.image_file_name.present?)
      extension = File.extname(image_file_name).downcase
      self.image_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end
end
