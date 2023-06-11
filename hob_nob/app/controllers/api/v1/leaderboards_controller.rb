class Api::V1::LeaderboardsController < ApplicationController
  respond_to :json

  def index
    mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_id(params["mobile_application_id"]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    
    # if params[:mobile_application_preview_code].present? 
    #   mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    # elsif params[:mobile_application_code].present? or params["mobile_application_id"].present?
    #   mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params[:mobile_application_code], params[:mobile_application_code]).first
    # end

    # event_status = (params[:mobile_application_code].present? ? ["published"] : ["approved","published"])

    event_status = (params[:mobile_application_code].present? and mobile_application.present? and mobile_application.submitted_code == params[:mobile_application_code].upcase) ? ["published"] : ["approved","published"]
    
		if mobile_application.present?
			if mobile_application.events.where('status =? or status =? or status =?', "approved", "published", "confirmed").present?
			  event = mobile_application.events.where(:id => params[:event_id]) rescue nil
      end
      if event.first.present?
			  user = Invitee.unscoped.find_by(:event_id => params[:event_id], :id => params[:invitee_id]) rescue nil
      end
			if user.present?
        if event.present?
  				invitees = Invitee.unscoped.where(:event_id => params[:event_id], :visible_status => 'active').order('points desc').first(5) rescue []
  				#invitees = invitees.first(5) if invitees.present?
  				present_ids = invitees.map{|invitee| invitee.id } if invitees.present?
  				if user.present? and !(present_ids.to_a.include?(user.id))
  					invitees << user
  				end
  				render :staus => 200, :json => {:status => "Success",:invitees => invitees.as_json(:only => [:id,:designation,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location,:invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :points, :first_name, :last_name], :methods => [:qr_code_url,:profile_pic_url, :rank]) } rescue []
  			else
  				render :status => 200, :json => {:status => "Failure", :message => "Event Not Found."}
  			end
      else
       render :status => 200, :json => {:status => "Failure", :message => "User Not Found."} 
       end  
    else
      render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
    end 
  end

end
