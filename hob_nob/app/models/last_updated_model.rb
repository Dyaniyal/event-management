class LastUpdatedModel < ActiveRecord::Base

  def self.update_record(name)
    #commented by Atul on 03-Oct-2018 as update was taking too long (around 60 sec) 
    #last_updated_model = LastUpdatedModel.find_or_initialize_by(:name => name)
    #last_updated_model.last_updated = Time.now
    #last_updated_model.save rescue nil
  end
end
