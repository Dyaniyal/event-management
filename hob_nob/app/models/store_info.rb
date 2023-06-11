class StoreInfo < ActiveRecord::Base

  attr_accessor :publish_hobnob

  belongs_to :mobile_application
  has_many :store_screenshots, :dependent => :destroy
  accepts_nested_attributes_for :store_screenshots

  has_attached_file :android_app_icon, {:styles => {:large => "640x640>",
                                         :small => "200x200>", 
                                         :thumb => "60x60>"},
                             :convert_options => {:large => "-strip -quality 90", 
                                         :small => "-strip -quality 80", 
                                         :thumb => "-strip -quality 80"}
                                         }.merge(ANDROID_APP_ICON_PATH)

  validates_attachment_content_type :android_app_icon, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"],:message => "please select valid format."

  has_attached_file :ios_app_icon, {:styles => {:large => "640x640>",
                                       :small => "200x200>", 
                                       :thumb => "60x60>"},
                           :convert_options => {:large => "-strip -quality 90", 
                                       :small => "-strip -quality 80", 
                                       :thumb => "-strip -quality 80"}
                                       }.merge(IOS_APP_ICON_PATH)

  # validates_attachment_content_type :ios_app_icon, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
  # validates_attachment_presence :android_app_icon, :message => "This field is required.", :if => :publish_by_hobnob
  validate :check_description_length
  validates :mobile_application_id,:android_email,:is_android_app, :is_ios_app, :android_title, :android_short_desc, :android_full_desc, :android_app_type, :android_category, :android_website, :android_phone, :android_policy_url, :android_country_list, :android_contains_ads, :android_content_guideline, :android_us_export_laws, :ios_keyword, :ios_support_url, :ios_copyright, :ios_contact_first_name, :ios_contact_last_name, :ios_demo_email, :ios_password, :mobile_application_id, presence:{ message: "This field is required." }, :if => :publish_by_hobnob

  validates :android_email, :presence =>true, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Sorry, this doesn't look like a valid email." }, :if => :publish_by_hobnob
  # validate :check_screenshots_pressence_and_count, :if => :publish_by_hobnob

  validates :android_phone,:presence => true, :numericality => true, :length => { :minimum => 10, :maximum => 15 }, :if => :publish_by_hobnob
  
  default_scope { order('created_at desc') }

  def publish_by_hobnob
    self.published_by_hobnob == 'yes' ? true : false
  end

  def check_description_length
    if self.android_full_desc.length > 4000
      errors.add(:android_full_desc, "maximum 4000 character allowed.")
    else
      errors.delete(:android_full_desc)
    end

    if self.android_short_desc.length > 80
      errors.add(:android_short_desc, "maximum 80 character allowed.")
    else
      errors.delete(:android_short_desc)
    end
  end  

  # def check_screenshots_pressence_and_count
  #   count_hsh = {"3.5-Inch" => '', "4-Inch" => '', "4.7-Inch" => '', "5.5-Inch" => '', "iPad" => '', "iPad Pro" => ''}
  #   android_count = {}
  #   self.store_screenshots.each do |store_screenshot|
  #     case store_screenshot.screen_type
  #     when 'Android'
  #       android_count[store_screenshot.screen_type] = android_count[store_screenshot.screen_type].to_i + 1 if store_screenshot.screen.present?
  #     when 'IOS'
  #       count_hsh[store_screenshot.screen_type] = count_hsh[store_screenshot.screen_type].to_i + 1 if store_screenshot.screen.present?
  #     end
  #   end
  #   ios_result = []
  #   count_hsh.each do |hsh|
  #     if (hsh.last != 5 ? true : false)
  #       ios_result << false
  #       obj = self.store_screenshots.map{|store_screenshot| store_screenshot.screen_type == hsh.first ? store_screenshot : nil}.compact.first
  #       obj.errors.add :screen, "Must be 5 images"
  #     end
  #   end
  #   android_result = android_count.values.sum < 2 ? [false] : [true]
  #   if android_result.include? false
  #     obj = self.store_screenshots.map{|store_screenshot| (['Phone', 'Tablet'].include? store_screenshot.screen_type) ? store_screenshot : nil}.compact.first
  #     obj.errors.add :screen, "Atleast 2 images required"
  #   end
  #   (ios_result.include? false or android_result.include? false) ? false : true
  # end
  
  # def image_url(style=:large)
  #   style.present? ? self.image.url(style) : self.image.url
  # end
end
