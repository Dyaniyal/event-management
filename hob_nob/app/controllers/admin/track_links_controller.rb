class Admin::TrackLinksController < ApplicationController
  
  layout 'admin'
  #load_and_authorize_resource
  #before_filter :authenticate_user, :authorize_event_role
  before_filter :find_event,:find_track_link
  skip_before_filter :authenticate_user, :load_filter, :only => ["show"]

  def create
    if params[:value].present?
      @track_link = @event.track_links.build
      @track_link.redirect_link = params[:value]
      @track_link.track_link_no = params[:track_link] if params[:track_link].present?
      if @track_link.save
        respond_to do |format|
          format.js
        end
      end
    end
  end

  def show
    @track_link.update_column(
      'link_count',
      @track_link.link_count.present? ? (@track_link.link_count.to_i + 1) : "1"
    )
    @track_link.track_user(params[:email])
    return redirect_to @track_link.redirect_link
  end

  private

  def find_event
    if params[:event_id].present?
      @event = Event.find(params[:event_id])
    end
  end

  def find_track_link
    if params[:id].present?
      @track_link = TrackLink.find_by_id(params[:id])
    end
  end

end
