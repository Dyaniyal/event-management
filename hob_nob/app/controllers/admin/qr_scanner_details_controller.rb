class Admin::QrScannerDetailsController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user, :authorize_event_role


  def index
  	@event = Event.where(:id=>params[:event_id])
    @badge_pdf = @event.first.badge_pdf#.find_by_event_id(params[:event_id])
    @attendees = Invitee.where(:qr_code_registration => true, :event_id => params[:event_id]).order('updated_at desc')
  end

  protected

  def authorize_event_role
    @event = Event.find_by_id(params[:event_id])
    if @event.blank?
      redirect_to admin_dashboards_path
    end
  end
end