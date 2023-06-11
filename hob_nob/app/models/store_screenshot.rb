class StoreScreenshot < ActiveRecord::Base
  belongs_to :store_infos
  has_attached_file :screen, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(APP_SCREENSHOT_PATH)

  validates_attachment_content_type :screen, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."

  
  default_scope { order('created_at desc') }
  
  def image_url(style=:large)
    style.present? ? self.screen.url(style) : self.screen.url
  end
end
