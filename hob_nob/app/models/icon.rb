class Icon < ActiveRecord::Base
  belongs_to :icon_liabrary
  has_attached_file :menu_icon, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(ICON_LIABRARY_MENU_ICON_IMAGE_PATH)

  has_attached_file :main_icon, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(ICON_LIABRARY_MAIN_ICON_IMAGE_PATH)

  validates_attachment_content_type :menu_icon, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_content_type :main_icon, :content_type => ["image/png"],:message => "please select valid format."
  validates :menu_icon, presence:{ :message => "This field is required." } 
  validates :main_icon, presence:{ :message => "This field is required." },:if => Proc.new{|p|["contacts","venue"].exclude?(p.icon_name)}
  validate :image_dimensions
  #before_save :rename_menu_icon_name,:rename_main_icon_name

  def image_dimensions
    if (self.menu_icon.present? and self.menu_icon_file_name_changed?)
      event_dimension_height_menu_icon, event_dimension_width_menu_icon  = 72.0, 72.0
      dimensions_menu_icon = Paperclip::Geometry.from_file(menu_icon.queued_for_write[:original].path)
      if (dimensions_menu_icon.width != event_dimension_width_menu_icon or dimensions_menu_icon.height != event_dimension_height_menu_icon)
        errors.add(:menu_icon, "Image size should be 72x72px only")
      end
    end

    if (self.main_icon.present? and self.main_icon_file_name_changed?)
      event_dimension_height_main_icon, event_dimension_width_main_icon  = 288.0, 288.0
      dimensions_main_icon = Paperclip::Geometry.from_file(main_icon.queued_for_write[:original].path)
      if (dimensions_main_icon.width != event_dimension_width_main_icon or dimensions_main_icon.height != event_dimension_height_main_icon)
        errors.add(:main_icon, "Image size should be 288x288px only")
      end
    end
  end  

  def rename_menu_icon_name
    if (self.menu_icon_updated_at_changed? and self.menu_icon_file_name.present?)
      extension = File.extname(menu_icon_file_name).downcase
      self.menu_icon_file_name = "#{self.icon_name}_menu_#{Time.now.to_i.to_s}#{extension}"
    end
  end

  def rename_main_icon_name
    if (self.main_icon_updated_at_changed? and self.main_icon_file_name.present?)
      extension = File.extname(main_icon_file_name).downcase
      self.main_icon_file_name = "#{self.icon_name}_main_#{Time.now.to_i.to_s}#{extension}"
    end
  end
end
