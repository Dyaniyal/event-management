class ConsentQuestionLookAndFeel < ActiveRecord::Base
	belongs_to :mobile_application
  has_attached_file :background_image, {:styles => {:small => "200x200>",
                                        :thumb => "60x60>",:large=>"1200x430"},
                            :convert_options => {:small => "-strip -quality 80",
                                              :thumb => "-strip -quality 80"}
                                              }.merge(CONSENT_QUESTION_LOOK_AND_FEEL_BACKGROUND_IMAGE_PATH)
  validates_attachment_content_type :background_image, :content_type => ["image/jpg", "image/jpeg", "image/png"],:message => "please select valid format."  
  validate :image_dimensions

  def image_dimensions
    if self.background_image_file_name_changed?  
      background_image_dimension_height  = 1600.0
      background_image_dimension_width = 960.0
      dimensions = Paperclip::Geometry.from_file(background_image.queued_for_write[:original].path)
      if (dimensions.width < background_image_dimension_width or dimensions.height < background_image_dimension_height)
        errors.add(:background_image, "Image size should be 960x1600px only") if self.errors['background_image'].blank?
      else
        self.errors.delete(:background_image)  
      end
    end
  end                                             
end
