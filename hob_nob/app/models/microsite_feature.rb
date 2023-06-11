class MicrositeFeature < ActiveRecord::Base
  include AASM

  belongs_to :event
  belongs_to :microsite
                                
  after_destroy :update_menu_saved_field_when_no_feature_selected

 
  default_scope { order("sequence") }
  aasm :column => :status do  # defaults to aasm_state
    state :active, :initial => true
    state :deactive
    
    event :active do
      transitions :from => [:deactive], :to => [:active]
    end 
     event :deactive do
      transitions :from => [:active], :to => [:deactive]
    end
  end 

  def set_status(microsite_feature)
    self.active! if microsite_feature== "active"
    self.deactive! if microsite_feature== "deactive"
  end


  def for_sequence_get_model_name
    {"microsite_feature"=> "MicrositeFeature","abouts" => "About", "agendas" => "Agenda", "speakers" => "Speaker" ,"emergency_exits" => "Venue", "faqs" => "FAQ", "images" => "Gallery","contacts" => "ContactUs", "sponsors" => "Sponsor"}

  end

  def update_menu_saved_field_when_no_feature_selected
    if self.microsite.microsite_features.blank?
      self.microsite.menu_saved = "false"
      self.microsite.save
      #self.event.update_column(:default_feature_icon, "custom") rescue nil
    end
  end
end
