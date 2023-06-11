class Admin::AnalyticsController < ApplicationController
  layout 'admin'

  before_filter :find_event,:authenticate_token, :if => proc {|p| current_user.blank?}# and request.params["token"].present?
  before_filter :authenticate_user, :authorize_event_role, :find_features, :if => proc {|p| current_user.present?}
  skip_before_action :load_filter, :if => proc {|c| (request.params["controller"] == "admin/analytics" and request.params["action"] == "index" and current_user.blank?)}
  def index
    if params[:print_preview].present?
      if params[:detailed_analytics].present? and @event.mobile_application.present?
        params[:filter_date], params[:start_date] = 'date range', params[:start_date].present? ? params[:start_date].to_date : Date.today - 2.weeks
        params[:end_date] = params[:end_date].present? ? params[:end_date].to_date : Date.today
        @detailed_analytics_counts = Analytic.get_detailed_analytics(params)
      elsif params[:analytics].present?  
        @live_analytics = Analytic.get_live_analytics(params)
      end
    else
      @analytics = @analytics.paginate(page: params[:page], per_page: 10)
    end
    respond_to do |format|
      format.html{
        render :layout => false if params[:print_preview].present?}
    end
  end

  protected
  
  def find_event
    @event = Event.find_by_id(params[:event_id])
  end

  def authenticate_token
    unless @event.present? and @event.token == params["token"]
      authenticate_user!
    end
  end
end