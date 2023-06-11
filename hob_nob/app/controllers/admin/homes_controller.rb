class Admin::HomesController < ApplicationController

  before_action :load_filter
  before_action :authenticate_user!
  
  def index
  	if current_user.present?
  		redirect_to admin_dashboards_path
	  end
	end
end