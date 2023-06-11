class Admin::ConversationWallsController < ApplicationController
  
  layout 'admin'
  before_filter :authenticate_user, :find_event
  
	def new
		@conversation_wall = ConversationWall.new
	end
	
  def create
		@conversation_wall = ConversationWall.new(conversation_wall_params)
    if @conversation_wall.save
      redirect_to admin_event_conversations_path(:event_id => @conversation_wall.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
  	@conversation_wall = ConversationWall.find(params[:id])
  end
  
  def update
    @conversation_wall = ConversationWall.find(params[:id])
    if params[:remove_logo_image] == "true"
      @conversation_wall.update_attribute(:logo, nil) if @conversation_wall.logo.present?
      redirect_to edit_admin_event_conversation_wall_path(:event_id => @event.id, :id => @conversation_wall.id)
    elsif params[:remove_bg_image] == "true"
      @conversation_wall.update_attribute(:background_image, nil) if @conversation_wall.background_image.present?
      redirect_to edit_admin_event_conversation_wall_path(:event_id => @event.id, :id => @conversation_wall.id)
    elsif @conversation_wall.update_attributes(conversation_wall_params)
      redirect_to admin_event_conversations_path(:event_id => @conversation_wall.event_id)
    else
      render :action => "edit"
    end
  end
	
  protected
	
  def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def conversation_wall_params
    params.require(:conversation_wall).permit!
  end

end
