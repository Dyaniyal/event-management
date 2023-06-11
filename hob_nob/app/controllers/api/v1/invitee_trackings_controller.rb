class Api::V1::InviteeTrackingsController < ApplicationController
  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  respond_to :json
  def index
    event = Event.find_by_id(params[:event_id])
    if event.present?
      data = {}
      sync_time = Time.now.utc.to_s
      start_event_date = params[:previous_date_time].present? ? (params[:previous_date_time].to_time.utc) : "01/01/1990 13:26:58".to_time.utc

      invitees = event.invitees.where("updated_at > ?", start_event_date)
      if invitees.present?
        invitees = Invitee.where(:event_id => event.id)
        render :status => 200, :json => {:status => "Success", :sync_time => sync_time,:invitees => invitees.as_json(:methods => [:venue_section_access]) }
        return
      else
        render :status => 200, :json => {:status => "Failure", :message => "Invitees Not Found."}
        return
      end
    else
      render :status=>200, :json=>{:status=>"Failure",:message=>"Event Not Found."}
    end
  end

  def create
    invitee = Invitee.find_by_id(params[:invitee_id])
    if (invitee.present? and params[:status].present?)
      if (params[:status] == "true" and invitee.successful_scan == false)
        invitee.update_attributes(:successful_scan => true)
        render :status => 200, :json => {:status => 'First time user',:invitee => invitee.as_json() }
      elsif (params[:status] == "true" and invitee.successful_scan == true)
        invitee.update_attributes(:previous_scan => true)
        render :status => 200, :json => {:status => 'Repeated user',:invitee => invitee.as_json() }
      elsif (params[:status] == "false")
        invitee.update_attributes(:previous_scan => false,:successful_scan => false)
        render :status => 200, :json => {:status => 'Not me',:invitee => invitee.as_json() }
      end
    else
      render :status=>200, :json=>{:status=>"Failure",:message=>"Invitee Not Found."}
    end
  end

  # def update
  #   invitee = Invitee.find_by_id(params[:id])
  #   if (invitee.present? and params[:status].present?)
  #     if (params[:status] == "true" and invitee.successful_scan == false)
  #       invitee.update_attributes(:previous_scan => true,:successful_scan => true)
  #       render :status => 200, :json => {:status => 'First time user',:invitee => invitee.as_json() }
  #     elsif (params[:status] == "true" and invitee.successful_scan == true)
  #       render :status => 200, :json => {:status => 'Repeated user',:invitee => invitee.as_json() }
  #     elsif (params[:status] == "false")
  #       invitee.update_attributes(:previous_scan => false,:successful_scan => false)
  #       render :status => 200, :json => {:status => 'Not me',:invitee => invitee.as_json() }
  #     end
  #   else
  #     render :status=>200, :json=>{:status=>"Failure",:message=>"Invitee Not Found."}
  #   end
  # end
  protected

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PATCH, PUT, OPTIONS'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == :options
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PATCH, PUT, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version'
      headers['Access-Control-Max-Age'] = '1728000'
      render :text => '', :content_type => 'text/plain'
    end
  end  
end
