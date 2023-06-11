class PollWall < ActiveRecord::Base
	

  require 'set_mult_lng_data'
	belongs_to :event
	
	has_attached_file :logo
  validates_attachment_content_type :logo, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  has_attached_file :logo, {:styles => {:large => "600x400>", 
                                       :thumb => "60x60>"}
                                       }.merge(POLLWALL_LOGO_PATH)
  has_attached_file :background_image
  validates_attachment_content_type :background_image, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  has_attached_file :background_image, {:styles => {:large => "1600x900>", 
                                       :thumb => "60x60>"}
                                       }.merge(POLLWALL_BG_IMAGE_PATH)
  
  validate :backgroung_image_validate
  validate :logo_image_validate
  validate :bg_image_or_bg_color_exist
  before_save :rename_logo_or_background_image_name
  after_create :update_multi_lng_model_data 
  validates :bar_color, :bar_color1, presence:{ :message => "This field is required." }  

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end
  def bg_image_or_bg_color_exist
    if self.background_image.blank? and self.background_color.blank?
      errors.add(:background_color, "This field is required.")
    end  
  end

  def backgroung_image_validate
    if self.background_image_file_name_changed?  
      background_image_dimension_height  = 900.0
      background_image_dimension_width = 1600.0
      dimensions = Paperclip::Geometry.from_file(background_image.queued_for_write[:original].path) rescue nil
      if dimensions.present? 
        if (dimensions.width != background_image_dimension_width or dimensions.height != background_image_dimension_height)
          errors.add(:background_image, "Image size should be 1600x900px only")
        end
      end
    end
  end
  
  def logo_image_validate 
    if self.logo_file_name_changed?  
      logo_dimension_height  = 300.0
      logo_dimension_width = 1280.0
      dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path) rescue nil
      if dimensions.present?
        if (dimensions.width != logo_dimension_width or dimensions.height != logo_dimension_height)
          errors.add(:logo, "Image size should be 1280x300px only")
        end
      end
    end
  end 

  def rename_logo_or_background_image_name
    if (self.logo_updated_at_changed? and self.logo_file_name.present?)
      extension = File.extname(logo_file_name).downcase
      self.logo_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
    if (self.background_image_updated_at_changed? and self.background_image_file_name.present?)
      extension = File.extname(background_image_file_name).downcase
      self.background_image_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end 
end
