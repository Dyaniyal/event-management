class CustomPage < ActiveRecord::Base
  self.abstract_class = true
  
  require 'set_mult_lng_data'

  belongs_to :event
  validates_presence_of :page_type, presence:{ :message => "This field is required." }
  validate :check_url_or_description_is_present
  validate :select_mapping_parameter
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data 
  before_save :set_open_with_on_page_type
  after_save :strip_white_spaces
  validate :strip_blanks
  
  def strip_white_spaces
    for count in 1..5  do
      if self.send("param#{count}_name").present?
        self.update_column(:"param#{count}_name", self.send("param#{count}_name").strip) 
      end
    end
  end  

  def strip_blanks
    for count in 1..5  do
      if self.send("param#{count}_name").present?
        value = self.send("param#{count}_name")
        param_name = value.strip.split
        if param_name.length > 1
          errors.add(:"param#{count}_name", "Spaces not allowed")
        end    
      end
    end
  end

  def select_mapping_parameter
    for count in 1..5  do
      if self.send("param#{count}_name").present? and self.send("param#{count}_value").blank?
        errors.add(:"param#{count}_value", "This field is required.")
      end
    end
  end

  def set_open_with_on_page_type
    self.open_with = 'in_app' if self.page_type == "build_new"
  end
  
  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end


  def check_url_or_description_is_present
    if self.page_type == "url" 
      errors.add(:site_url, "This field is required.") if self.site_url.blank?
      errors.add(:open_with, "This field is required.") if self.open_with.blank?
    end
    if self.page_type == "build_new"
      errors.add(:description, "This field is required.") if self.description.blank?
    end
  end

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_site_url
    if self.page_type == "build_new"
      self.update_column(:site_url, "#{APP_URL}/admin/events/#{self.event_id}/custom_page1s/#{self.id}")
    end
  end

  def get_redirection_url(invitee)
    if invitee.present?
      url = self.site_url+"?"
      for i in 1..5 do
        if self.send("param#{i}_name").present?
          url = url + "&" if i != 1
          url = url + self.send("param#{i}_name") + "=" + invitee.send(self.send("param#{i}_value")).to_s
        end
      end
    else
      url = self.site_url
    end
    url.gsub(" ","")
  end

end
