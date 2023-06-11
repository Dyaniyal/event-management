class Admin::PollWallsController < ApplicationController
  
  layout 'admin'
  before_filter :authenticate_user, :find_event
  
	def new
		@poll_wall = PollWall.new
	end
	
  def create
		@poll_wall = PollWall.new(poll_wall_params)
    if @poll_wall.save
      redirect_to admin_event_polls_path(:event_id => @poll_wall.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
  	@poll_wall = PollWall.find(params[:id])
  end
  
  def update
    @poll_wall = PollWall.find(params[:id])
    if params[:remove_logo_image] == "true"
      @poll_wall.update_attribute(:logo, nil) if @poll_wall.logo.present?
      redirect_to edit_admin_event_poll_wall_path(:event_id => @event.id, :id => @poll_wall.id)
    elsif params[:remove_bg_image] == "true"
      @poll_wall.update_attribute(:background_image, nil) if @poll_wall.background_image.present?
      redirect_to edit_admin_event_poll_wall_path(:event_id => @event.id, :id => @poll_wall.id)
    elsif @poll_wall.update_attributes(poll_wall_params)
      redirect_to admin_event_polls_path(:event_id => @poll_wall.event_id)
    else
      render :action => "edit"
    end
  end
	
  protected
	
  def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def poll_wall_params
    params.require(:poll_wall).permit!
  end

end
