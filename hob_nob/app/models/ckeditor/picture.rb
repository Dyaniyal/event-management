class Ckeditor::Picture < Ckeditor::Asset
  # has_attached_file :data,
  #                   :url  => "/ckeditor_assets/pictures/:id/:style_:basename.:extension",
  #                   :path => ":rails_root/public/ckeditor_assets/pictures/:id/:style_:basename.:extension",
  #                   :styles => { :content => '800>', :thumb => '118x100#' }.

  has_attached_file :data, {:styles => {:content => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:content => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(CKEDITOR_IMAGE_PATH)

  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 2.megabytes
  validates_attachment_content_type :data, :content_type => /\Aimage/

  def url_content
    url(:content)
  end
end
