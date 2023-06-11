class Admin::QuizWallsController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user, :find_event
  
	def new
		@quiz_wall = QuizWall.new
	end
	
  def create
		@quiz_wall = QuizWall.new(quiz_wall_params)
    if @quiz_wall.save
      redirect_to admin_event_quizzes_path(:event_id => @quiz_wall.event_id)
    else
      render :action => 'new'
    end
	end

	def edit
  	@quiz_wall = QuizWall.find(params[:id])
  end
  
  def update
    @quiz_wall = QuizWall.find(params[:id])
    if params[:remove_logo_image] == "true"
      @quiz_wall.update_attribute(:logo, nil) if @quiz_wall.logo.present?
      redirect_to edit_admin_event_quiz_wall_path(:event_id => @event.id, :id => @quiz_wall.id)    
    elsif params[:remove_bg_image] == "true"
      @quiz_wall.update_attribute(:background_image, nil) if @quiz_wall.background_image.present?
      redirect_to edit_admin_event_quiz_wall_path(:event_id => @event.id, :id => @quiz_wall.id)
    elsif @quiz_wall.update_attributes(quiz_wall_params)
      redirect_to admin_event_quizzes_path(:event_id => @quiz_wall.event_id)
    else
      render :action => "edit"
    end
  end
	
  protected
	
  def find_event
		@event = Event.find(params[:event_id])
	end	
	
	def quiz_wall_params
    params.require(:quiz_wall).permit!
  end

end
