class Admin::QnaWallsController < ApplicationController
  
  layout 'admin'
  before_filter :authenticate_user, :find_event
  
	def new
		@qna_wall = QnaWall.new
	end
	
  def create
		@qna_wall = QnaWall.new(qna_wall_params)
    if @qna_wall.save
      redirect_to admin_event_qnas_path(:event_id => @qna_wall.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
  	@qna_wall = QnaWall.find(params[:id])
  end
  
  def update
    @qna_wall = QnaWall.find(params[:id])
    if params[:remove_logo_image] == "true"
      @qna_wall.update_attribute(:logo, nil) if @qna_wall.logo.present?
      redirect_to edit_admin_event_qna_wall_path(:event_id => @event.id, :id => @qna_wall.id)
    elsif params[:remove_bg_image] == "true"
      @qna_wall.update_attribute(:background_image, nil) if @qna_wall.background_image.present?
      redirect_to edit_admin_event_qna_wall_path(:event_id => @event.id, :id => @qna_wall.id)
    elsif @qna_wall.update_attributes(qna_wall_params)
      redirect_to admin_event_qnas_path(:event_id => @qna_wall.event_id)
    else
      render :action => "edit"
    end
  end
	
  protected
	
  def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def qna_wall_params
    params.require(:qna_wall).permit!
  end

end