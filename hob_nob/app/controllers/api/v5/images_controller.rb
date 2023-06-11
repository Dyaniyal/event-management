class Api::V5::ImagesController < ApplicationController
  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  before_filter :check_preview_code, :only => [:index]
  before_filter :check_mobile_application, :only => [:index]
  before_filter :check_for_event, :only => [:index]
  respond_to :json
  
  def index
    data = Image.get_records(params)   
    render :staus => 200, :json => {:status => "Success",
                                     :galleries => data }
                                  
  end

  protected

  def check_for_event
    event_status = ((params[:mobile_application_code].present? and @mobile_application.present? and @mobile_application.submitted_code == params[:mobile_application_code].upcase) ? ["published"] : ["approved","published"])
    @event = @mobile_application.events.where(:id => params[:event_id], :status => event_status) rescue nil
    if @event.blank?
      render :status => 200, :json => {:status => "Failure", :message => "Event Not Found."}
    end
  end

  def check_preview_code
    @mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_id(params["mobile_application_id"]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])   
  end

  def check_mobile_application
    if @mobile_application.blank?
      render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
    end 
  end
end
#http://localhost:3000/api/v5/images.json?event_id=677&mobile_application_code=PHAJAM&authentication_token=v58p-KAVsK24zRMAx-iz&key=3224e1e629bd13fcdc680b9b3a4aed69eda20db6