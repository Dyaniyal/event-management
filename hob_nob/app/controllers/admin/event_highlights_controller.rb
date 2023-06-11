class Admin::EventHighlightsController < ApplicationController

  layout 'admin'
  before_filter :authenticate_user, :find_event

  def index
    @highlight_image = @event.highlight_images
  end

  def new
    @highlight_image = @event.highlight_images.build
    @highlight_images = @event.highlight_images
    if @event.summary.present? or @event.description.present?
      redirect_to edit_admin_event_event_highlight_path(:event_id => @event.id, :id => @event.id)
    end
  end

  def create
    message = true
    message  = @event.validate_rsvp_text(params)  if params[:event].present? and (params[:event][:rsvp].present? and ["yes","Yes"].include?(params[:event][:rsvp]))
    if message and @event.update_attributes(events_params)
      @event.update_column(:highlight_saved, "saved")
      # redirect_to new_admin_event_event_highlight_path(@event)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
    else
      @event.update_column(:rsvp, params[:event][:rsvp]) if params[:event].present? and params[:event][:rsvp].present?
      @highlight_image = @event.highlight_images.build
      @highlight_images = @event.highlight_images
      render :action => "new"
    end
  end

  def destroy
  end

  def edit
    @highlight_image = @event.highlight_images.build
    @highlight_images = @event.highlight_images
  end
  
  def show
  end

  protected

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end

  def events_params
    if @event.login_at == "Before Interaction"
      params[:event]["rsvp"] = "No" rescue nil
      params[:event]["rsvp_message"] = "" rescue nil
    end
    params.require(:event).permit!.except(:features)
  end

end
