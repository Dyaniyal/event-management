class Contact < ActiveRecord::Base
	
  require 'set_mult_lng_data'
  belongs_to :event
	validates :event_id, presence: { :message => "This field is required." }
  validates :email,
            :format => {
              :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
              :message => "Sorry, this doesn't look like a valid email." }
  after_save :update_last_updated_model
  after_create :update_multi_lng_model_data
  after_destroy :remove_multi_lng_model_data
	default_scope { order('created_at desc') }

  def remove_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngSequence.remve_mlt_lng_data(self) #if agenda parent event deleted then multilngdata also deleted.
    end
  end
  
  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def update_multi_lng_model_data
    if self.parent_id.blank?
      SetMultLngData.set_model_details(self)
    end 
  end  
end
