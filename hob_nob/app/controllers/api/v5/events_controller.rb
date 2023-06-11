class Api::V5::EventsController < ApplicationController
	require "sync_mobile_data_v5"
 
  respond_to :json
  before_filter :check_date, :only => :index
  before_filter :set_date, :only => :index
  before_filter :check_mobile_application_code, :only => :index
  before_filter :capture_request, :configure_cache_params
  caches_action :index, 
                :cache_path => Proc.new { |c| c.params["controller"].to_s+c.params["previous_date_time"].to_s+c.params["mobile_application_code"].to_s+c.params["event_id"].to_s+c.params["is_invitee_group"].to_s}, 
                :expires_in => 2.minutes.to_i,
                :if => Proc.new{|c| c.params["hard_refresh"] != "true"}

  def index
    data = SyncMobileDataV5.sync_records(params)
    render :status => 200, :json => { :status => "Success",
                                      :sync_time => Time.now.utc.to_s,
                                      :application_type => @mobile_application.application_type,
                                      :social_media_status => @mobile_application.social_media_status,
                                      :login_at_after_splash => @mobile_application.login_at,
                                      :data => data
                                    }
  end 

  protected 

  def check_date
    begin
      Date.parse(params[:previous_date_time]) if params[:previous_date_time].present?
    rescue Exception => e
      render :status => 200, :json => {:status => "Failure", :message => "Provide correct Date Format."}
      return
    end
  end

  def set_date
    if params[:previous_date_time].present?
      params[:previous_date_time] = params[:previous_date_time].to_time.change(:sec => 0).utc.to_s
    else
      params[:previous_date_time] = "01/01/1990 13:26:00".to_time.utc
    end
  end

  def check_mobile_application_code
    if params[:mobile_application_code].present?
      @mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code])
      if @mobile_application.blank?
        render :status => 200, :json => {:status => "Failure", :message => "Provide mobile application preview code or submitted code."}
      else
        create_device_token
      end
    else
      render :status => 200, :json => {:status => "Failure", :message => "Provide mobile application preview code or submitted code."}
    end
  end

  def create_device_token
    if (params[:device_token].present? and params[:platform].present?) and @mobile_application.present?
      device = Device.where(:token => params[:device_token]).first
      if device.present?
        device.update(:mobile_application_id => @mobile_application.id, :enabled => 'true')
      else
        Device.create(:token => params[:device_token], :platform => params[:platform],:mobile_application_id => @mobile_application.id, :enabled => 'true')
      end
    end
  end

  def capture_request
    TrackApi.create(  :request_params => params, 
                      :key => params[:key],
                      :event_id => params[:event_id], 
                      :source => params[:source],
                      :previous_date_time => params[:previous_date_time]
                    )
  end
end

# Mobile APIS

# multi event app 
# http://localhost:3000/api/v5/events.json?mobile_application_code=SQVWWP

# single event app 
# http://localhost:3000/api/v5/events.json?mobile_application_code=PBMGFI

# multi event app with event id and user key 
# http://localhost:3000/api/v5/events.json?mobile_application_code=SQVWWP&previous_date_time=&key=8e97a1e5a3cc7031a9585653e81b65a6d2b1670b&authentication_token=aAUZd7UxjC5HxXrXjfi_&event_id=711

# single event app with event id and user key 
# http://localhost:3000/api/v5/events.json?mobile_application_code=PBMGFI&previous_date_time=&key=048d08d599cf26ab3e1aa6470b7a46de87e19089&authentication_token=nWAXaj4qnzxWXqkF_ebs&event_id=602

# hard refresh
# http://localhost:3000/api/v5/events.json?mobile_application_code=PBMGFI&previous_date_time=&key=048d08d599cf26ab3e1aa6470b7a46de87e19089&authentication_token=nWAXaj4qnzxWXqkF_ebs&event_id=602&hard_refresh=true