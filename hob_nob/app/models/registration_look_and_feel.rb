class RegistrationLookAndFeel < ActiveRecord::Base
  
  require 'set_mult_lng_data'

  belongs_to :event
  after_create :update_multi_lng_model_data 

  has_attached_file :logo, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(REGISTRATION_LOOK_AND_FEEL_LOGO_PATH)
  has_attached_file :banner_image, {:styles => {:small => "200x200>",
                                         :thumb => "60x60>",:large=>"1200x430"},
                             :convert_options => {:small => "-strip -quality 80",
                                         :thumb => "-strip -quality 80"}
                                         }.merge(REGISTRATION_LOOK_AND_FEEL_BANNER_IMAGE_PATH)
  has_attached_file :body_background_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>",:large => "1600x960"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(REGISTRATION_LOOK_AND_FEEL_BODY_IMAGE_PATH)                                                   
  has_attached_file :footer_image, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(REGISTRATION_LOOK_AND_FEEL_FOOTER_IMAGE_PATH)

  validates_attachment_content_type :logo,:banner_image,:body_background_image,:footer_image, :content_type => ["image/png"],:message => "please select valid format."  
  validate :image_dimensions
  validate :file_field
  #validates :logo, presence:{ :message => "This field is required." }
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end 

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
        errors.add(:banner_image, "Image size should be 1600x500px or above only") if self.errors['banner_image'].blank?
      else
        self.errors.delete(:banner_image)  
      end
    end
    if self.footer_image_file_name_changed?  
      footer_dimension_height  = 50.0
      footer_dimension_width = 200.0
      dimensions = Paperclip::Geometry.from_file(footer_image.queued_for_write[:original].path)
      if (dimensions.width != footer_dimension_width or dimensions.height != footer_dimension_height)
        errors.add(:footer_image, "Image size should be 200x50px only") if self.errors['footer_image'].blank?
      else
        self.errors.delete(:footer_image)  
      end
    end
    if self.body_background_image_file_name_changed?  
      body_background_dimension_width = 1600
      dimensions = Paperclip::Geometry.from_file(body_background_image.queued_for_write[:original].path)
      if (dimensions.width != body_background_dimension_width)
        errors.add(:body_background_image, "Image width should be 1600px only") if self.errors['body_background_image'].blank?
      else
        self.errors.delete(:body_background_image)  
      end
    end
  end

  def file_field
    errors.messages
      .select { |k,v| k.to_s.end_with? ('_content_type') }
      .each { |k,v| errors.add(k.to_s.sub('_content_type', ''), v.join(', ')) if errors[k.to_s.sub('_content_type', '').to_sym].blank? }
  end

end