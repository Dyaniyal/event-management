class Api::V1::VisitorRegistrationsController < ApplicationController
  skip_before_action :load_filter
  before_filter :get_events, :only => [:new,:create]
  
  def index
    
  end
  def new
    if @events.present?
      @events.each do |event|
        @invitee = event.invitees.build
      end
    else
      @invitee = Invitee.new
    end
  end

  def create
    if @events.present?
      @events.each do |event|
        @invitee = event.invitees.build(invitee_params)
        @invitee.set_invitee_password
        @invitee.save
      end
      if @invitee.errors.present?
        render :action => 'new'
      else
        redirect_to api_v1_visitor_registrations_path(:status=>'1')
      end
    else
      redirect_to api_v1_visitor_registrations_path
    end
  end

  protected
  def get_events
    if (params[:mobile_application_code].present? || (params[:invitee].present? and params[:invitee][:mobile_application_code].present?))
      if params[:mobile_application_code].present?
        mobile_applications = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) 
      else
        mobile_applications = MobileApplication.find_by_submitted_code(params[:invitee][:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:invitee][:mobile_application_code])
      end
      if mobile_applications.present?
        @events = Event.where("mobile_application_id IN (?) and event_type_for_registration = ?", [mobile_applications.id], "open")
        @background_color = mobile_applications.visitor_registration_background_color
        @background_image = mobile_applications.visitor_registration_background_image.url if mobile_applications.visitor_registration_background_image_file_name.present?
      end
    else
      redirect_to api_v1_visitor_registrations_path
    end  
  end

  def invitee_params
    params.require(:invitee).permit!
  end
end
