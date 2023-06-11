class EventGroup < ActiveRecord::Base
  resourcify
  belongs_to :client
  default_scope { order('created_at desc') }

  def self.search(params, event_groups)
    keyword = params[:search][:keyword]
    event_groups = event_groups.where("name like (?)", "%#{keyword}%")if keyword.present?
    event_groups 
  end
end
