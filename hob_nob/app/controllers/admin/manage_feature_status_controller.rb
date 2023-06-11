class Admin::ManageFeatureStatusController < ApplicationController
	layout 'admin'

	def index
		features = params[:feature].constantize.where(:event_id => params[:event_id]) if params[:feature].present? and params[:event_id].present?
		features.update_all(:status => params[:status]) if features.present? and params[:status].present?
    redirect_to request.referer
	end
	
end
