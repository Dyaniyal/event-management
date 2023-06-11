class MicrositeLookAndFeel < ActiveRecord::Base
	belongs_to :event
  belongs_to :microsite

  has_attached_file :logo, {:styles => {:small => "160x65>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(MICROSITE_LOOK_AND_FEEL_LOGO_PATH)
  has_attached_file :banner_image, {:styles => {:small => "200x200>",
                                         :thumb => "60x60>",:large=>"1200x430"},
                             :convert_options => {:small => "-strip -quality 80",
                                         :thumb => "-strip -quality 80"}
                                         }.merge(MICROSITE_LOOK_AND_FEEL_BANNER_IMAGE_PATH)

  validates_attachment_content_type :logo,:banner_image, :content_type => ["image/jpg", "image/jpeg", "image/png"],:message => "please select valid format."  
  validate :image_dimensions
  #validates :logo, presence:{ :message => "This field is required." }

  def image_dimensions
    if self.logo_file_name_changed?  
      logo_dimension_height  = 70.0
      logo_dimension_width = 450.0
      dimensions = Paperclip::Geometry.from_file(logo.queued_for_write[:original].path)
      if (dimensions.width != logo_dimension_width or dimensions.height != logo_dimension_height)
        errors.add(:logo, "Image size should be 450x70px only") if self.errors['logo'].blank?
      else
        self.errors.delete(:logo)
      end
    end
    if self.banner_image_file_name_changed?  
      banner_dimension_height  = 500.0
      banner_dimension_width = 1600.0
      dimensions = Paperclip::Geometry.from_file(banner_image.queued_for_write[:original].path)
      if (dimensions.width < banner_dimension_width or dimensions.height < banner_dimension_height)
        errors.add(:banner_image, "Image size should be 1600x500px only") if self.errors['banner_image'].blank?
      else
        self.errors.delete(:banner_image)  
      end
    end
  end
end
