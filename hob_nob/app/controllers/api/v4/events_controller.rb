class Api::V4::EventsController < ApplicationController
	require "sync_mobile_data_v4"
 
  respond_to :json
  before_filter :check_date, :only => :index
  before_filter :configure_cache_params, :only => :index
  caches_action :index, :cache_path => Proc.new { |c| c.params["test"].to_s+c.params["controller"].to_s+c.params["previous_date_time"].to_s+c.params["mobile_application_code"].to_s+c.params["event_id"].to_s+c.params["is_invitee_group"].to_s }, :expires_in => 2.minutes.to_i
  #caches_action :index, :cache_path => Proc.new { |c| c.params }, :expires_in => 2.minutes.to_i

  def index
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
        allow_ids = invitee.get_event_id(mobile_application.submitted_code,submitted_app)
        if params[:event_id].present? and allow_ids.exclude? params[:event_id].to_i
          event_ids  = [0]
        elsif allow_ids.exclude?(invitee.event_id)
          event_ids  = [0]
        else
          event_ids = allow_ids  
        end
      end 
      status = (submitted_app == "Yes" ? ["published"] : ["approved", "published"])
      # all_events = mobile_application.events.where(:status => status)
      all_events = mobile_application.events.where("status IN (?)", status)
      # all_updated_events = all_events.where(:updated_at => start_event_date...end_event_date)
      all_updated_events = all_events.where("updated_at between (?) and (?)", start_event_date,end_event_date)
      all_event_ids = all_events.pluck(:id)
      all_updated_event_ids = all_updated_events.pluck(:id)
      event_ids ||= all_event_ids
      all_event_ids_data = (params[:event_id].present? ? [] : all_event_ids)
      if params[:event_id].present?
        if !event_ids.include? params[:event_id].to_i and event_ids.present?
          event_ids  = [0]
        else
          event_ids = [params[:event_id].to_i]
        end
      else
        if mobile_application.marketing_app_event_id.present?
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
      event = Event.where("id IN (?)", event_ids).as_json(:except => [:multi_city, :city_id, :logo_file_name, :logo_content_type, :logo_file_size,:inside_logo_file_name,:inside_logo_content_type,:inside_logo_file_size], :methods => [:logo_url,:inside_logo_url, :about_date, :event_start_time_in_utc, :display_time_zone,:footer_image_url]) if params[:event_id].present?   # Event.where(:id => event_ids)
      
      event_ids_not_have_access = (all_event_ids - allow_ids)

      event_ids_if_no = (invitee.present? ? (mobile_application.all_events_listing == "no") ? (mobile_application.event_listing_display_updated_at.present? and (mobile_application.event_listing_display_updated_at >= start_event_date.to_time.utc)) ? allow_ids : [] : [] : (mobile_application.all_events_listing == "no") ? [] : all_event_ids) if (mobile_application.application_type.present? and mobile_application.application_type == "multi event")

      event_ids_if_yes = (invitee.present? ? (mobile_application.all_events_listing == "yes") ? (mobile_application.event_listing_display_updated_at.present? and (mobile_application.event_listing_display_updated_at >= start_event_date.to_time.utc)) ? all_event_ids : [] : [] : (mobile_application.all_events_listing == "no") ? [] : all_event_ids) if (mobile_application.application_type.present? and mobile_application.application_type == "multi event")

      all_events_event_ids = event_ids_if_no.present? ? event_ids_if_no : event_ids_if_yes

      event_ids_dont_have_access = event_ids_if_no.present? ? event_ids_not_have_access : []
      all_events_listing_data = Event.where("id IN (?)", all_events_event_ids).as_json(:only => [:id, :event_name, :cities, :venues, :logo_updated_at, :status, :inside_logo_updated_at, :theme_id, :login_at, :event_category, :marketing_app, :start_event_time, :end_event_time, :description, :parent_id, :multi_lng_parent_id, :primary_language], :methods => [:logo_url,:inside_logo_url,:about_date]) # Event.where(:id => all_events_event_ids)
      
      all_updated_events_data = Event.where("id IN (?)", all_updated_event_ids).as_json(:only => [:id, :event_name, :cities, :venues, :logo_updated_at, :status, :inside_logo_updated_at, :theme_id, :login_at, :event_category, :marketing_app, :start_event_time, :end_event_time, :description, :parent_id, :multi_lng_parent_id, :primary_language], :methods => [:logo_url,:inside_logo_url,:about_date])
      # params[:event_id].present? ? [] :  # Event.where(:id => all_updated_event_ids)

      events_having_access = Event.where("id IN (?)", allow_ids).as_json(:only => [:id, :event_name, :cities, :venues, :logo_updated_at, :status, :inside_logo_updated_at, :theme_id, :login_at, :event_category, :marketing_app, :start_event_time, :end_event_time, :description, :parent_id, :multi_lng_parent_id, :primary_language], :methods => [:logo_url,:inside_logo_url,:about_date]) # Event.where(:id => allow_ids)

      all_events_data = (mobile_application.all_events_listing == "no" and all_updated_events_data.present?) ? events_having_access : (all_updated_events_data + all_events_listing_data).uniq

      #all_events_data = (mobile_application.all_events_listing == "no" and all_updated_events_data.present?) ? (Event.where(:id => allow_ids) - all_updated_events_data) : (all_updated_events_data + all_events_listing_data).uniq

      invitee_email = Invitee.find(mobile_current_user.id).email rescue nil
      if invitee_email.blank?
        invitee_user = mobile_current_user
      else
        invitee_user = Invitee.where(event_id: event_ids, email: invitee_email).first
      end
      data = SyncMobileDataV4.sync_records(start_event_date, end_event_date, mobile_application.id, invitee_user,submitted_app, event_ids, all_updated_event_ids,hard_refresh)
      
if params[:test]=="1"
  agenda = data[:agenda]
  ids = agenda.map {|a| a["id"]}
  agendas = ids & [3975, 4016, 4004, 4013, 4031, 4049, 4040, 4077, 4051]
  render :status => 200, :json => {:start_event_date => start_event_date, :end_event_date => end_event_date, :mobile_application_id => mobile_application.id, :mobile_current_user => invitee_user.id, :submitted_app => submitted_app, :event_ids => event_ids, :all_updated_event_ids => all_updated_event_ids, :hard_refresh => hard_refresh, :agendas => agendas }
else
      render :status => 200, :json => {:status => "Success", :sync_time => sync_time, :application_type => mobile_application.application_type, :social_media_status => mobile_application.social_media_status, :login_at_after_splash => mobile_application.login_at, :event_ids => allow_ids, :selected_event => (event_ids.present? ? event_ids : []), :all_events => all_events_data,:event => (event.present? ? event : []),:listing_display_event_ids => all_events_event_ids.present? ? all_events_event_ids : [],:event_ids_dont_have_access => event_ids_dont_have_access.present? ? event_ids_dont_have_access : [],:data => data}
end      
      # render :status => 200, :json => {:status => "Success", :sync_time => sync_time, :application_type => mobile_application.application_type, :social_media_status => mobile_application.social_media_status, :login_at_after_splash => mobile_application.login_at, :event_ids => allow_ids, :selected_event => (event_ids.present? ? event_ids : []), :all_events => (params[:event_id].present? ? [] : all_events_data),:event => (event.present? ? event : []),:listing_display_event_ids => all_events_event_ids,:event_ids_dont_have_access => event_ids_dont_have_access.present? ? event_ids_dont_have_access : [],:data => data}


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
