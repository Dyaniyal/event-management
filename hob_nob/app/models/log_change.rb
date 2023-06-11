class LogChange < ActiveRecord::Base
  belongs_to :user

  after_save :update_last_updated_model

  default_scope {order('updated_at')}

  def update_last_updated_model
    LastUpdatedModel.update_record(self.class.name)
  end

  def self.get_changes(resourse_type, resourse_id)
    LogChange.where(:resourse_type => resourse_type, :resourse_id => resourse_id)
  end

end
