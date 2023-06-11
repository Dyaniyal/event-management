class Microsite < ActiveRecord::Base
  serialize :preferences
  attr_accessor :get 

  MICROSITE_ASSOCIATIONS = [ 'microsite_look_and_feel', 'microsite_features']

  belongs_to :event
  has_one :microsite_look_and_feel, :dependent => :destroy
  has_many :microsite_features, :dependent => :destroy
  accepts_nested_attributes_for :microsite_features
  before_save :check_microsite_content_status
  validates :name,  presence: { :message => "This field is required." }
  validate :check_registration_link, if: Proc.new { |p| p.get.present? }
  validate :registration_url_with_http, if: Proc.new { |p| p.get.present? }
  MICROSITE_FEATURE_ARR = ['agendas','speakers', 'faqs', 'images', 'contacts', 'sponsors', 'emergency_exits']
  

  def registration_url_with_http
    if self.registration_url.present?
      value = self.registration_url
      unless  value.include? "https://" or value.include? "http://"
        errors.add(:registration_url, "Please include http:// or https:// infront of the url")
      end
    end
  end

  def check_registration_link
    if self.registration_url == ""
      errors.add(:registration_url, "This field is required.")
    end
  end


  def check_microsite_content_status 
    features = self.microsite_features.pluck(:name) 
    not_enabled_feature = Microsite::MICROSITE_FEATURE_ARR - features
    count = 0
    total_content_count = features.count 
    content_missing_arr = []
    features.each do |feature|
      (feature != 'emergency_exits' and feature != 'emergency_exit')#condition = self.event.association(feature).count <= 0 if !(feature == 'abouts') and 
      condition, feature = EmergencyExit.where(:event_id => self.event.id).blank?, 'emergency_exits' if (feature == 'emergency_exits' or feature == 'emergency_exit')
      if (condition or (feature == 'abouts' and self.event.about.blank?))
        count += 1
        content_missing_arr << feature
      end
    end
    percent = (((count/total_content_count.to_f) * 100) == 0.0)? 100 : (100 - ((count/total_content_count.to_f) * 100)) if total_content_count != 0
    [content_missing_arr, not_enabled_feature, (percent.to_i/10) * 10]
  end

  def review_look_and_feel
    feature_arr = ['logo_file_name', 'banner_image_file_name']
    count = 0
    total_count = nil
    total = total_count || feature_arr.length
    missing_arr = []
    feature_arr.each do |feature|
      if self.microsite_look_and_feel.present? and self.microsite_look_and_feel.attribute_present? (feature)
        count += 1
      else
        missing_arr << feature
      end
    end
    [(((((count/total.to_f) * 100).to_i) / 10) * 10), missing_arr]
  end

  def review_features
    self.microsite_features.where("name != ?", "").present? ? 100 : 0
  end

  def review_menus
    percentage = 0
    total = 0
    features = self.microsite_features
    feature_length = features.length
    total = feature_length * 2 if feature_length.present?
    count = 0
    missing_data = []
    features.each do |feature|
      feature.page_title.present? ? count = count + 1 : (missing_data << {:feature => feature.name})
      total = total - 1
    end
    percentage = (count * 100)/(total)  if total != 0
    [percentage,missing_data]
  end

  def microsite_review_status
    features_arr = ['name']
    count = 0
    total_count=nil
    total = total_count || features_arr.length
    missing_arr = []
    features_arr.each do |feature|
      if self.attribute_present? (feature)
        count += 1
      else
        missing_arr << feature
      end
    end
    [(((((count/total.to_f) * 100).to_i) / 10) * 10), missing_arr]
  end

  def review_status(type)
    case type
      when 'app_info'
        per = self.microsite_review_status[0]
      when 'look_and_feel'
        per = self.review_look_and_feel[0]
      when 'features'
        per = self.review_features
      when 'menus'
        per = self.review_menus[0]
      when 'content'
        per = self.check_microsite_content_status[2]
    end
    per
  end

  def get_data(event, page_type)
    if page_type == "agenda"
      data =  {}
      keys = event.agendas.group("DATE(start_agenda_time)").count
      keys.each do |key,value|
        data[key] = event.agendas.where('Date(start_agenda_date) = ?', key) if key.present?
      end
      data
    end
  end

  def add_microsite_features(params)
    if params[:microsite].present?
      params[:microsite][:features] = params[:microsite][:features].present? ? params[:microsite][:features] : []
      already_feature = self.microsite_features.pluck(:name) 
      feature_delete = already_feature.select { |elem| (!params[:microsite][:features].include?(elem))  }
      feature_delete.each {|f| self.microsite_features.where(:name => f).destroy_all}
      feature_to_add = params[:microsite][:features] - already_feature if params[:microsite][:features].present?
      feature_to_add.each_with_index do |f,i|
        seq = self.microsite_features.present? ? self.microsite_features.pluck(:sequence).compact.max.to_i + 1 : 1  
        microsite_feature = self.microsite_features.new(name: f, page_title: Client::display_hsh2[f], sequence: seq, status: "active")
        microsite_feature.save
      end
    else
      self.microsite_features.destroy_all
      self.update_column(:default_feature_icon, "new_menu")
    end
  end

  def update_microsite_features_from_menu(microsite_features)
    microsite_features[:microsite_features_attributes].each do |feature_hash|
      feature_record = feature_hash[1]
      feature = self.microsite_features.find(feature_record["id"]) rescue nil
      feature.update_attributes(feature_record) if feature.present?
    end
  end

  def add_single_microsite_features(params)
    unless event.microsite.microsite_features.pluck(:name).include?(params[:enable])
      seq = event.microsite.microsite_features.present? ? event.microsite.microsite_features.pluck(:sequence).compact.max.to_i + 1 : 1 rescue 1
      feature = params["enable"] 
      feature = event.microsite.microsite_features.new(name: feature, page_title: Client::display_hsh2[feature], sequence: seq)
      feature.save
    end
  end

  def for_sequence_get_model_name
    {"agendas" => "Agenda", "speakers" => "Speaker" ,"emergency_exits" => "Venue", "faqs" => "FAQ", "images" => "Gallery", "contacts" => "ContactUs", "sponsors" => "Sponsor", "custom_page1s" => "Custom Page 1", "custom_page2s" => "Custom Page 2", "custom_page3s" => "Custom Page 3", "custom_page4s" => "Custom Page 4", "custom_page5s" => "Custom Page 5", "custom_page6s" => "Custom Page 6", "custom_page7s" => "Custom Page 7", "custom_page8s" => "Custom Page 8", "custom_page9s" => "Custom Page 9", "custom_page10s" => "Custom Page 10"}
  end

  def remove_single_microsite_features(params)
    features = event.microsite.microsite_features
    feature_name = (params["disable"])    
    feature = features.find_by_name(feature_name)
    feature.destroy if feature.present?
    if event.microsite.microsite_features.blank?
      event.microsite.update_column(:default_feature_icon, "new_menu")
    end
  end

  def set_microsite_features_default_list()
    default_features = ["agendas", "speakers", 'emergency_exits', "faqs", "images",  "contacts", "sponsors", "registrations" , 'custom_page1s', 'custom_page2s', 'custom_page3s', 'custom_page4s', 'custom_page5s',"custom_page6s","custom_page7s","custom_page8s","custom_page9s","custom_page10s"]
  end


  def set_microsite_features
    present_feature = event.microsite.microsite_features.pluck(:name) 
  end

  def get_associated_microsite_module_data(feature,id)
    feature.find_by_id(id)
  end

  def decide_seq_no(seq_type,feature,featue_type)
    if featue_type == Image
      microsite = feature.imageable
      objects = featue_type.where(:imageable_id => microsite.id)
    elsif featue_type == AgendaTrack
       microsite = feature.microsite
       objects = featue_type.joins(:agendas).where(:microsite_id => microsite.id,:agenda_date =>feature.agenda_date.to_date).uniq.order(:sequence)
    else
      microsite = feature.microsite
      objects = featue_type.where(:microsite_id => microsite.id)
    end
    ids = objects.pluck(:id) 
    position = ids.index(feature.id)
    if seq_type == "up"
      previous_sp = objects.find_by_id(ids[position.to_i - 1])
      old_seq = previous_sp.sequence
      previous_sp.update(:sequence => feature.sequence)
      feature.update(:sequence => old_seq)
    else
      next_sp = objects.find_by_id(ids[position.to_i + 1])
      next_seq = next_sp.sequence
      next_sp.update(:sequence => feature.sequence)
      feature.update(:sequence => next_seq)
    end if ids.length > 1
  end


  def get_active_features
    self.microsite_features.where(:status => "active")
  end

  def get_category_faq_setting_status
    faq = self.microsite_features.where(:name => "faqs")
    if faq.present?
      faq.first.faq_setting.downcase rescue ""
    else
      ""
    end
  end

  def get_gallery_folder_setting_status
    gallery = self.microsite_features.where(:name => "images")
    if gallery.present?
      gallery.first.image_setting.downcase rescue ""
    else
      ""
    end
  end
end
