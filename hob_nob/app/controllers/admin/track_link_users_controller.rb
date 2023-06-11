class Admin::TrackLinkUsersController < ApplicationController
  layout 'admin'
  skip_before_filter :authenticate_user!
  skip_before_filter :load_filter
  before_filter :authorize_event_role
  def index
    if (params[:email_count] == "true" and params[:edm_id].present?)
      @all_track_link_users = EdmMailSent.where('edm_id =? and open =?', params[:edm_id], "yes").reverse.paginate(page: params[:page], per_page: 10)
    elsif (params[:email_count] == "true" and params[:event_id].present?)
      @all_track_link_users = EdmMailSent.where('event_id =? and open =?', params[:event_id], "yes").reverse.paginate(page: params[:page], per_page: 10)
    end
  	if params[:track_link_no].present? and params[:edm_id].present?
      @track_link_users = TrackLinkUser.where('track_link_no =? and edm_id =?', params[:track_link_no], params[:edm_id]).reverse.paginate(page: params[:page], per_page: 10)
    else 
      @track_link_users = TrackLinkUser.where('track_link_no =? and event_id =?', params[:track_link_no], @event.id).reverse.paginate(page: params[:page], per_page: 10)
    end 
    respond_to do |format|
      format.html 
      format.xls do
        only_columns = [:email]
        method_allowed = [:Timestamp]
        if (params[:email_count] == "true" and params[:edm_id].present?) 
          @track_link_users = EdmMailSent.where('edm_id =? and open =?', params[:edm_id], "yes").reverse
        elsif (params[:email_count] == "true" and params[:event_id].present?)
          @track_link_users = EdmMailSent.where('event_id =? and open =?', params[:event_id], "yes").reverse
        elsif params[:edm_id].present?
          @track_link_users = TrackLinkUser.where('track_link_no =? and edm_id =?', params[:track_link_no], params[:edm_id]).reverse
        else
          @track_link_users = TrackLinkUser.where('track_link_no =? and event_id =?', params[:track_link_no], @event.id).reverse
        end
        if params[:email_count] == "true"
          send_data @track_link_users.to_xls(:only => only_columns, :methods => method_allowed), filename: "open_emails.xls"
        else
          send_data @track_link_users.to_xls(:only => only_columns, :methods => method_allowed), filename: "tracked_users#{params[:track_link_no]}.xls"
        end
      end
    end
  end 
end
