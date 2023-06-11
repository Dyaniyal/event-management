class Api::V1::EKitsController < ApplicationController
	skip_before_action :load_filter
	skip_before_action :authenticate_user!
	respond_to :json
	
	def index
		# mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code]) || MobileApplication.find_by_id(params["mobile_application_id"])
		# event_status = (params[:mobile_application_code].present? ? ["published"] : ["approved","published"]) 
		if params[:mobile_application_preview_code].present?
	    mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    elsif params[:mobile_application_code].present? or params["mobile_application_id"].present?
			mobile_application = MobileApplication.where('submitted_code =? or preview_code =? or id =?', params[:mobile_application_code], params[:mobile_application_code], params["mobile_application_id"]).first
		end
    event_status = (params[:mobile_application_code].present? and mobile_application.submitted_code == params[:mobile_application_code]) ? ["published"] : ["approved","published"]
    
		if mobile_application.present?
			events = mobile_application.events rescue nil
			event = events.where(:id => params[:event_id], :status => event_status) rescue nil
			if event.present?
				data = EKit.get_e_kits(event)
				render :staus => 200, :json => {:status => "Success",:e_kits => data } rescue []
			else
				render :status => 200, :json => {:status => "Failure", :message => "Event Not Found."}
			end	
		else
			render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
		end	
	end
end
