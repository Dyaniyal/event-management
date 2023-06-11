class BadgePdf < ActiveRecord::Base
  belongs_to :event
  #validates_uniqueness_of :event_id,:message => "Badge image for Event already set."
  serialize :sequence, Array
  serialize :qr_code_attr, Hash
  serialize :field1_parameters, Hash
  serialize :field2_parameters, Hash
  serialize :field3_parameters, Hash
  serialize :field4_parameters, Hash
  validate :scan_bg_image_validate #,:badge_image_validate
  validates :top, :left, :font_size, :numericality => {:message => "Enter Numeric numbers only."}, :allow_nil => true
  validates :badge_height, :badge_width,
            numericality: { message: "Enter Numeric values only." },
            allow_nil: true, allow_blank: true
  has_attached_file :badge_image

  validates_attachment_content_type :badge_image, :content_type => ["image/png", "image/jpg", "image/jpeg"],:message => "please select valid format."
  
  has_attached_file :badge_image, {:styles => {:large => "396x554>", 
                                       :thumb => "60x60>"}
                                       }.merge(BADGE_IMAGE_PATH)
  has_attached_file :scan_bg_image, {:styles => {:large => "1600x900>", 
                                       :thumb => "60x60>"}
                                       }.merge(SCAN_BG_IMAGE_PATH)


  def badge_image_validate
    if self.badge_image_file_name_changed?  
      badge_dimension_height  = 554.0
      badge_dimension_width = 396.0
      dimensions = Paperclip::Geometry.from_file(badge_image.queued_for_write[:original].path)
      if (dimensions.width != badge_dimension_width or dimensions.height != badge_dimension_height)
        errors.add(:badge_image, "Image size should be 396x554px only")
      end
    end
  end
  def scan_bg_image_validate
    if self.scan_bg_image_file_name_changed?  
      badge_dimension_height  = 900.0
      badge_dimension_width = 1600.0
      dimensions = Paperclip::Geometry.from_file(scan_bg_image.queued_for_write[:original].path)
      if (dimensions.width != badge_dimension_width or dimensions.height != badge_dimension_height)
        errors.add(:scan_bg_image, "Image size should be 1600x900px only")
      end
    end
  end

  ['field1', 'field2', 'field3', 'field4'].each do |field|
    define_method("#{field}_styles") do
      selected_style = self.send("#{field}_parameters")[:font_style]
      font_style = if selected_style == "italic"
        "font-style: italic;"
      elsif selected_style == 'bold'
        "font-weight: bold;"
      end
      font_size = self.send("#{field}_parameters")[:font_size] || "15"
      "#{font_style} font-size: #{font_size}px"
    end
  end
end