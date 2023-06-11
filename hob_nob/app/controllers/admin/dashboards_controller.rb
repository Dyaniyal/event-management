class Admin::DashboardsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user
  
  def index
    @count = Event.with_role(session[:current_user_role], current_user)
    client_ids = Client.with_role(session[:current_user_role], current_user).pluck(:id)
    if client_ids.present?
      @count += Event.where(:client_id => client_ids,:marketing_app => nil)
      @count = @count.flatten.uniq
    end
  end
  
end
