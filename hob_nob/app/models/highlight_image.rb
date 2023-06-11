class HighlightImage < ActiveRecord::Base

  require 'set_mult_lng_data'

  belongs_to :event                                       

  has_attached_file :highlight_image, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(HIGHLIGHT_IMAGE_PATH)
  
  validates_attachment_content_type :highlight_image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."
  after_create :update_multi_lng_model_data
  after_save :update_last_updated_model
  before_save :rename_highlight_image_name
	
  def update_multi_lng_model_data
    if self.parent_id.blank?
      multi_lng_Event = Event.where(parent_id:self.event_id)
      if multi_lng_Event.present?
        multi_lng_Event.each do |event|
          new_objekt = HighlightImage.new
          new_objekt.name = self.name
          new_objekt.highlight_image = self.highlight_image if self.highlight_image_file_name.present?
          new_objekt.event_id = event.id
          new_objekt.parent_id = self.parent_id
          new_objekt.language_updated = self.language_updated
          new_objekt.created_at = self.created_at
          new_objekt.updated_at = self.updated_at
          new_objekt.save
        end
      end   
    end 
  end  
  def highlight_image_url(style=:large)
  	if self.parent_id.present? and not self.highlight_image.exists?
      parent = HighlightImage.find(self.parent_id)
      style.present? ? parent.highlight_image.url(style) : parent.highlight_image.url
    else
      style.present? ? self.highlight_image.url(style) : self.highlight_image.url
    end
	end

  def to_jq_upload
    {
      "name" => read_attribute(:highlight_image),
      "size" => highlight_image.size,
      "url" => highlight_image.url(:thumb),
      "thumbnail_url" => highlight_image.url(:thumb),
      "delete_url" => highlight_image.url(:thumb),
      "delete_type" => "DELETE" ,
      "id" => self.id
    }
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def rename_highlight_image_name
    if (self.highlight_image_updated_at_changed? and self.highlight_image_file_name.present?)
      extension = File.extname(highlight_image_file_name).downcase
      self.highlight_image_file_name = "#{Time.now.to_i.to_s}#{extension}"
    end
  end
end
