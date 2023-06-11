class Api::V1::EventsController < ApplicationController
 require "sync_mobile_data"
 
  respond_to :json
  before_filter :check_date, :only => :index

  skip_filter :find_clients, :set_current_user
  skip_filter :telecaller_is_login
  caches_action :index, :cache_path => Proc.new { |c| c.params }, :expires_in => 2.minutes.to_i

  def index
    mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    # submitted_app = "Yes" if params[:mobile_application_code].present? 
    
    # if params[:mobile_application_preview_code].present?
    #   mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    # elsif params[:mobile_application_code].present?
    #   mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params[:mobile_application_code], params[:mobile_application_code]).first
    # end

    submitted_app = "Yes" if params[:mobile_application_code].present? and mobile_application.present? and mobile_application.submitted_code == params[:mobile_application_code].upcase
    if mobile_application.present?
      sync_time = Time.now.utc.beginning_of_minute.to_s
      start_event_date = params[:previous_date_time].present? ? (params[:previous_date_time]) : "01/01/1990 13:26:58".to_time.utc
      end_event_date = Time.now.utc + 2.minutes
      allow_ids = []
      invitee = Invitee.find_by_key(params[:key])
      if invitee.present?
        submitted_app = ((params[:mobile_application_code].present? and mobile_application.submitted_code == params[:mobile_application_code].upcase) ? "Yes" : "No")
        allow_ids = invitee.get_event_id_api(mobile_application.submitted_code,submitted_app,start_event_date,end_event_date)
      end  
      data = SyncMobileData.sync_records(start_event_date, end_event_date, mobile_application.id, mobile_current_user,submitted_app) 
      render :staus => 200, :json => {:status => "Success", :sync_time => sync_time, :application_type => mobile_application.application_type, :social_media_status => mobile_application.social_media_status, :login_at_after_splash => mobile_application.login_at, :event_ids => allow_ids, :data => data }
    else
      render :status => 200, :json => {:status => "Failure", :message => "Provide mobile application preview code or submitted code."}
    end 
  end 
  
  def create
    chanages_done = []
    params[:platform] = params[:platform].present? ? params[:platform] : "" 
    changes_done = {}
    params["data"].each do |key, value|
      data = SyncMobileData.select_model(key,value,params[:platform])
      changes_done[key.constantize.table_name] = data if ["UserFeedback", "UserQuiz", "UserPoll","Rating","MyProfile","Invitee","Favorite","InviteeNotification","Comment","Conversation","Like","Qna"].include? key
      if ["UserFeedback"].include? key
        feddback_data = []
        data.each do |d|
          feddback_data << {:feedback_form_id=>d["feedback_form_id"],:user_id=>d["user_id"]}
        end
        invitee_ids = feddback_data.uniq
        # invitees = Invitee.where("id IN (?)",invitee_ids)
        # feedback_form_ids = feddback_data.map{|data| data[:feedback_form_id]}.uniq #UserFeedback.unscoped.where(:user_id => invitee_ids).pluck("distinct feedback_form_id")
        hsh = []
        invitee_ids.each do |invitee|
            user_feedbacks = UserFeedback.where(:feedback_form_id => invitee[:feedback_form_id], :user_id => invitee[:user_id]).order("updated_at")
            hsh << {"invitee_id" => invitee[:user_id],"feedback_form_id" => invitee[:feedback_form_id], "last_updated" => user_feedbacks.last.updated_at} if user_feedbacks.present?
        end 
        changes_done["all_feedback_forms_last_updated_at"] = hsh #if ["UserFeedback"].include? key
      end
      if ["Analytic"].include? key
        hsh = []
        data.each do |d|
          if d["viewable_type"] == "E-Kit" and d["viewable_id"].blank?
            hsh << d
          end
        end
        changes_done[key.constantize.table_name] = hsh
      end
    end 
    render :status => 200, :json => {:status => "Success", :response => changes_done}
    return
  end

  def delete_mobile_data
    deleted_id = [] 
    params["data"].each do |key, value|
      case key
        when "Like"
          deleted_id << SyncMobileData.delete_record(value,"Like")
        when "Favorite"
          deleted_id << SyncMobileData.delete_record(value,"Favorite")
      end
    end 
    render :status => 200, :json => {:status => "Success", :deleted_id => deleted_id.flatten!}
    return
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
end
