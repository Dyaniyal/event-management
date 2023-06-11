class EmergencyExit < ActiveRecord::Base
  
  require 'set_mult_lng_data'
  belongs_to :event
  has_attached_file :emergency_exit,{}.merge(Emergency_Exit_IMAGE_PATH)
  has_attached_file :icon, {:styles => {:small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(Emergency_Exit_icon_IMAGE_PATH)

  validates_attachment_content_type :emergency_exit, :content_type => ['application/pdf', 'application/msword', 'text/plain',"image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."
  validates_attachment_content_type :icon, :content_type => ["image/png"],:message => "please select valid format."
  validates_attachment_presence :emergency_exit,:message => "This field is required."
  validates :title, presence: { :message => "This field is required." } 
  validate :image_dimensions

  after_create :update_multi_lng_model_data
  before_save :update_event_name,:rename_icon_or_emergency_exit_name
  after_save :update_last_updated_model
  
  default_scope { order('created_at desc') }

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end 
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_event_name
  	self.event_name = Event.find_by_id(self.event_id).event_name rescue nil
  end

  def emergency_exit_url
    if self.parent_id.present? and not self.emergency_exit.exists?
      parent = EmergencyExit.find(self.parent_id)
      parent.emergency_exit.url
    else
      self.emergency_exit.url
    end
  end

  def icon_url
    if self.parent_id.present? and not self.icon.exists?
      parent = EmergencyExit.find(self.parent_id)
      parent.icon.url
    else
      self.icon.url
    end
  end

  def attachment_type
    file_type = self.emergency_exit_content_type.split("/").last rescue ""
    file_type
  end

   def image_dimensions
    if self.icon_file_name_changed? and self.parent_id.blank? 
      icon_dimension_height  = 288.0
      icon_dimension_width = 288.0
      dimensions = Paperclip::Geometry.from_file(icon.queued_for_write[:original].path)
      if (dimensions.width != icon_dimension_width or dimensions.height != icon_dimension_height)
        errors.add(:icon, "Icon size should be 288x288px only")
      else
        self.errors.delete(:icon)
      end
    end
  end
  
  def rename_icon_or_emergency_exit_name
    if (self.emergency_exit_updated_at_changed? and self.emergency_exit_file_name.present?)
      extension = File.extname(emergency_exit_file_name).downcase
      self.emergency_exit_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
    if (self.icon_updated_at_changed? and self.icon_file_name.present?)
      extension = File.extname(icon_file_name).downcase
      self.icon_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end    
  end  
end
