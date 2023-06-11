class Api::V5::LeaderboardsController < ApplicationController
	respond_to :json
  before_filter :check_preview_code, :only => [:index]
  before_filter :check_for_mobile_application, :only => [:index]
  before_filter :check_for_user, :only => [:index]
  before_filter :check_for_event, :only => [:index]

	def index
    data = Invitee.get_records(params)
		render :staus => 200, :json => {:status => "Success",
                                    :invitees => data } rescue []
	end
  
  protected

  def check_preview_code
    @mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_id(params["mobile_application_id"]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
  end

  def check_for_mobile_application
    if @mobile_application.blank?
      render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
    end 
  end
  
  def check_for_user
   event_status = (params[:mobile_application_code].present? and @mobile_application.present? and @mobile_application.submitted_code == params[:mobile_application_code].upcase) ? ["published"] : ["approved","published"]
    @event = @mobile_application.events.where(:id => params[:event_id], :status => event_status) rescue nil
    @user = Invitee.unscoped.find_by(:event_id => params[:event_id], :id => params[:invitee_id]) rescue nil
    if @user.blank?
      render :status => 200, :json => {:status => "Failure", :message => "User Not Found."} 
    end  
  end

  def check_for_event
    if @event.blank?
      render :status => 200, :json => {:status => "Failure", :message => "Event Not Found."}
    end
  end
end
#with out invitee id:- localhost:3000/api/v5//leaderboards.json?authentication_token=1WFx8mKPv7NSx1KgkYHK&key=c261db70913bb7ca28d695bc17ac8f1d05a1ed54&mobile_application_code=PAIBKA&event_id=635&invitee_id=
#with invitee id :- localhost:3000/api/v5//leaderboards.json?authentication_token=r61zZG8gB_KefARp6Y5V&key=afc18f10f203ad9dc7ed6523b130e1b036df6c5e&mobile_application_code=PHEDAI&event_id=168&invitee_id=7045