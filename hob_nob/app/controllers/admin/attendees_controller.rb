class Admin::AttendeesController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  
  def index
    @attendees = Attendee.search(params, @attendees) if params[:search].present?
    @attendees = @attendees.paginate(:page => params[:page], :per_page => 10)      
  end

  def new
    @attendee = @event.attendees.build
  end

  def create
    @attendee = @event.attendees.build(attendee_params)
    if @attendee.save
      redirect_to admin_event_attendees_path(:event_id => @attendee.event_id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @attendee.update_attributes(attendee_params)
      redirect_to admin_event_attendees_path(:event_id => @attendee.event_id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @attendee.destroy
      redirect_to admin_event_attendees_path(:event_id => @attendee.event_id)
    end
  end

  protected

  def attendee_params
    params.require(:attendee).permit!
  end
end
