class Theme < ActiveRecord::Base
 
  require 'set_mult_lng_data'

  has_many :events
  belongs_to :created_user, :foreign_key => :created_by, :class_name => 'User'
  
  accepts_nested_attributes_for :events
  
  has_attached_file :event_background_image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(THEME_IMAGE_PATH)


  validates_attachment_content_type :event_background_image, :content_type => ["image/png"],:message => "please select valid format."

	validates :content_font_color,:button_color,:button_content_color,:drawer_menu_back_color,:drawer_menu_font_color,:bar_color, presence: { message: "This field is required." } #,:header_color,:footer_color
  #validates :name, uniqueness: true, if: Proc.new { |b| b.licensee_id.blank? }
  #validates :name, uniqueness: { scope: :licensee_id }, if: Proc.new { |b| b.licensee_id.present? }
  validate :image_dimensions
  validate :check_whether_event_bacground_image_or_bacground_color_present

  after_save :update_last_updated_model
  # before_save :rename_event_background_image_name
  after_create :update_multi_lng_model_data 
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def check_presence_of_event_id
    # if event_id == nil
      errors.add :event_id, "You must select an Event" if event_id == nil
    # end
  end

  def event_background_image_url(style=nil)
    if self.parent_id.present? and not self.event_background_image.exists?
      parent = Theme.find(self.parent_id)
      style.present? ? parent.event_background_image.url(style) : parent.event_background_image.url
    else
      style.present? ? self.event_background_image.url(style) : self.event_background_image.url
    end
  end

	def self.search(params, themes)
    name = params[:search][:keyword]
    themes = themes.where("name like (?)","%#{name}%") if name.present? 
  end

  def self.find_themes(event=nil)
    theme = []
    theme = Theme.where(:admin_theme => true)
    theme << event.theme if event.present?
    theme
  end  


  def image_dimensions
    if self.event_background_image_file_name_changed? and self.parent_id.blank?
      theme_dimension_height  = 1600.0
      theme_dimension_width = 960.0
      dimensions = Paperclip::Geometry.from_file(event_background_image.queued_for_write[:original].path) rescue "Creating copy" 
      if (dimensions != "Creating copy" and (dimensions.width != theme_dimension_width or dimensions.height != theme_dimension_height))
        errors.add(:event_background_image, "Image size should be 960x1600 px only")
      end
    end
  end

  def is_admin_theme?
    self.admin_theme?
  end
  
  def is_preview?
    Theme.where(:admin_theme => true, :preview_theme => "yes").first.id == self.id rescue nil
  end

  def check_whether_event_bacground_image_or_bacground_color_present
    if self.background_color.blank? and self.event_background_image_file_name.blank?
      errors.add(:background_color, "Select Background Color") if self.background_color.blank?
      errors.add(:event_background_image, "Select Background Image") if self.event_background_image.blank?
    end
  end

  def rename_event_background_image_name
    if (self.event_background_image_updated_at_changed? and self.event_background_image_file_name.present?)
      extension = File.extname(event_background_image_file_name).downcase
      self.event_background_image_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end
end
