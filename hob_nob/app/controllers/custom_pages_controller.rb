class CustomPagesController < ApplicationController
  skip_before_action :load_filter
  before_action :check_paramters
  layout false

  def index
    event = Event.find(params[:event_id]) 
    @custom_page = event.send(params[:page_type]).last
    invitee = Invitee.find(params[:invitee_id]) rescue nil
    if @custom_page.present? and @custom_page.page_type == "url"
      if request.path.include? "events"
        redirect_url = get_redirection_url(@custom_page, invitee)
      else
        redirect_url = @custom_page.get_redirection_url(invitee)
      end
      redirect_to redirect_url
    end
  end

  protected
    def check_paramters
      if params[:page_type].blank? or params[:event_id].blank? 
        redirect_to root_path, :status => 301
      end
    end

    def get_redirection_url(custom_page, invitee)
      if invitee.present?
        url = custom_page.site_url+"?email=" + invitee.email.to_s + "&first_name=" + invitee.first_name.to_s + "&last_name=" + invitee.last_name.to_s
      else
        url = custom_page.site_url
      end
    end
end

# http://localhost:3000/events/602/custom_pages?page_type=custom_page1s&invitee_id=
