class Api::V2::EventsController < ApplicationController
	require "sync_mobile_data"
 
  respond_to :json
  before_filter :check_date, :only => :index
  caches_action :index, :cache_path => Proc.new { |c| c.params }, :expires_in => 2.minutes.to_i

  def index
    # mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code])
    # if mobile_application.present? 
    #   submitted_app = "Yes" 
    # else
    #   mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_code])
    # end
    mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    submitted_app = "Yes" if params[:mobile_application_code].present? and mobile_application.present? and mobile_application.submitted_code == params[:mobile_application_code].upcase
    hard_refresh = params[:hard_refresh] if params[:hard_refresh].present?
    if mobile_application.present?
      sync_time = Time.now.utc.to_s
      start_event_date = params[:previous_date_time].present? ? (params[:previous_date_time]) : "01/01/1990 13:26:58".to_time.utc
      end_event_date = Time.now.utc + 2.minutes
      allow_ids = []
      invitee = Invitee.find_by_key(params[:key]) if params[:key].present?
      if invitee.present?
        #submitted_app = (params[:mobile_application_code].present? ? "Yes" : "No")
        allow_ids = invitee.get_event_id(mobile_application.submitted_code,submitted_app)
        if params[:event_id].present? and allow_ids.exclude? params[:event_id].to_i
          #render :status => 200, :json => {:status => "Failure",:message => "Invitee does not have access to that Event"} and return
          event_ids  = [0]
        elsif allow_ids.exclude?(invitee.event_id)
          #render :status => 200, :json => {:status => "Failure",:message => "Invitee does not have access to that Event"} and return
          event_ids  = [0]
        else
          event_ids = allow_ids  
        end
      end
      status = (submitted_app == "Yes" ? ["published"] : ["approved", "published"])
      all_events = mobile_application.events.where(:status => status)
      all_updated_events = all_events.where(:updated_at => start_event_date...end_event_date)
      all_event_ids = all_events.pluck(:id)
      all_updated_event_ids = all_updated_events.pluck(:id)
      event_ids ||= all_event_ids
      all_event_ids = (params[:event_id].present? ? [] : all_event_ids)
      if params[:event_id].present?
        if !event_ids.include? params[:event_id].to_i and event_ids.present?
          #render :status => 200, :json => {:status => "Failure",:message => "Invalid event_id"} and return
          event_ids  = [0]
        else
          event_ids = [params[:event_id].to_i]
        end
      else
        if mobile_application.marketing_app_event_id.present?# and event_ids.include?(mobile_application.marketing_app_event_id.to_i)
          marketing_app = Event.find(mobile_application.marketing_app_event_id)
          if status.include?(marketing_app.status)
            event_ids = [mobile_application.marketing_app_event_id.to_i] 
          else
            event_ids = [0]
          end
        else
          event_ids  = [0] if mobile_application.application_type != "single event"
        end
      end
      event = Event.where(:id => event_ids).as_json(:except => [:multi_city, :city_id, :logo_file_name, :logo_content_type, :logo_file_size,:inside_logo_file_name,:inside_logo_content_type,:inside_logo_file_size], :methods => [:logo_url,:inside_logo_url, :about_date, :event_start_time_in_utc, :display_time_zone,:footer_image_url]) if params[:event_id].present?
      all_events_data = Event.where(:id => all_updated_event_ids).as_json(:only => [:id, :event_name, :cities, :venues, :logo_updated_at, :status, :inside_logo_updated_at, :theme_id, :login_at, :event_category, :marketing_app, :start_event_time, :end_event_time], :methods => [:logo_url,:inside_logo_url])
      data = SyncMobileData.sync_records(start_event_date, end_event_date, mobile_application.id, mobile_current_user,submitted_app, event_ids, all_updated_event_ids,hard_refresh) 
      render :status => 200, :json => {:status => "Success", :sync_time => sync_time, :application_type => mobile_application.application_type, :social_media_status => mobile_application.social_media_status, :login_at_after_splash => mobile_application.login_at, :event_ids => allow_ids, :selected_event => (event_ids.present? ? event_ids : []), :all_events => (params[:event_id].present? ? [] : all_events_data),:event => (event.present? ? event : []),:data => data}
    else
      render :status => 200, :json => {:status => "Failure", :message => "Provide mobile application preview code or submitted code."}
    end 
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

  # def get_event_ids(event_ids)
  #   hsh = {}
  #   for event in Event.where(:id => event_ids)
  #   	binding.pry
  #     hsh[event.id] = ((Time.now + event.timezone_offset) - event.start_event_time.strftime("%d %m %Y %H:%M %P").to_datetime).abs
  #   end
  #   closest_event_id = hsh.sort_by(&:last).first.first  
  #   [closest_event_id]
  # end

  def get_event_ids(event_ids)
   ongoing = Event.where(:id => event_ids,:event_category=>"Ongoing")
   if ongoing.present?
   	closest_event_id = ongoing.first.id
   	return [closest_event_id]
   end
   upcoming = Event.where(:id => event_ids,:event_category=>"Upcoming")
   if upcoming.present?
   	closest_event_id = upcoming.first.id
   	return [closest_event_id]
   end
   past = Event.where(:id => event_ids,:event_category=>"Past")
   if past.present?
   	closest_event_id = past.last.id
   	return [closest_event_id]
   end
  end	
end
