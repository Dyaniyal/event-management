class Image < ActiveRecord::Base
	
  require 'set_mult_lng_data'
  require 'set_mult_lng_sequence'
  
  belongs_to :imageable, polymorphic: true
  belongs_to :folder
  has_many :favorites, as: :favoritable, :dependent => :destroy
  has_attached_file :image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(PICTURE_IMAGE_PATH)

  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."
  
  before_create :set_sequence_no
  before_save :rename_image_name
  after_create :update_multi_lng_model_data
  after_save :update_multi_lng_sequence
  after_destroy :remove_multi_lng_model_data
  default_scope { order('sequence') }
  
  def remove_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) #if agenda parent event deleted then multilngdata also deleted.
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
  
  def image_url(style=:large)
  	if self.parent_id.present? and not self.image.exists?
      parent = Image.find(self.parent_id)
      style.present? ? parent.image.url(style) : parent.image.url
    else
      style.present? ? self.image.url(style) : self.image.url
    end
  end

  def set_sequence_no
    if self.parent_id.blank?
      self.sequence = (Event.find(self.imageable_id).images.pluck(:sequence).compact.max.to_i + 1)rescue nil
    end
  end

  def folder_name
    return self.folder.present? ? self.folder.name : ""
  end

  def folder_sequence
    return self.folder.present? ? self.folder.sequence : ""
  end

  def to_jq_upload
    {
      "name" => read_attribute(:image),
      "size" => image.size,
      "url" => image.url(:thumb),
      "thumbnail_url" => image.url(:thumb),
      "delete_url" => image.url(:thumb),
      "delete_type" => "DELETE" ,
      "id" => self.id
    }
  end

  def rename_image_name
    if (self.image_updated_at_changed? and self.image_file_name.present?)
      extension = File.extname(image_file_name).downcase
      self.image_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end
  def self.get_records(params)
    data = {}
    @mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_id(params["mobile_application_id"]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])   
    event_status = ((params[:mobile_application_code].present? and @mobile_application.present? and @mobile_application.submitted_code == params[:mobile_application_code].upcase) ? ["published"] : ["approved","published"])
    events = @mobile_application.events 
    @event = events.where(:id => params[:event_id], :status => event_status)
    event = @event
    galleries = Image.where(:imageable_id => event.first.id,:imageable_type => "Event") 
    data[:galleries] = galleries.as_json(:except => [:image_file_name,
                                                     :image_content_type,
                                                     :image_file_size,
                                                     :image_updated_at],
                                          :methods => [:image_url]) 
  end
end
