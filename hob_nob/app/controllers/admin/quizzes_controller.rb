class Admin::QuizzesController < ApplicationController
	layout 'admin'
  
  before_filter :authenticate_user, :authorize_event_role, :find_features, :except => [:index]
  skip_before_action :load_filter, :only => [:index] 
  before_filter :find_user_quizzes, :only => [:index, :new]
  before_filter :find_quiz_wall, :only => :index
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role, :except => [:index]
  before_filter :quiz_wall_present, :only => [:index]
  before_filter :find_groups, :only => [:new, :create, :edit, :update]

	def index
    if params[:quiz_wall].present? and params[:quiz_wall] == "true"
      @quizzes = @quizzes.where(:on_wall => "yes")   
      render :layout => false
    else  
      @quizzes = Quiz.search(params, @quizzes) if params[:search].present?
      #@quizzes = @quizzes.paginate(page: params[:page], per_page: 10)
      respond_to do |format|
        format.html  
        format.xls do
          only_columns = [:question, :option1, :option2, :option3, :option4, :option5, :option6, :status]
          method_allowed = []
          send_data @quizzes.to_xls(:only => only_columns)
        end
      end
	  end
  end

	def new
		@quiz = @event.quizzes.build
    @import = Import.new if params[:import].present?
	end

	def create
		@quiz = @event.quizzes.build(quizze_params)
    if @quiz.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_engagement")
      else
        redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
      end
    else
      render :action => 'new'
    end
	end

	def edit
	end

	def update
    # if params[:status].present?
    #   @quiz.change_status(params[:status])
    #   redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
    if params[:status].present? or params[:on_wall].present?
      @quiz.update_column(:on_wall, params[:on_wall]) if params[:on_wall].present?
      @quiz.change_status(params[:status]) if params[:status].present?
      @quiz.update_last_updated_model
      if params[:status].present? and @quiz.parent_id.blank?
        @multi_lng_quizs = Quiz.where(parent_id:@quiz.id)
        @multi_lng_quizs.update_all(status: params[:status])
      end 
      redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
    else
      if !(quizze_params.key?(:correct_ans_option4) or  quizze_params.key?(:correct_ans_option1) or  quizze_params.key?(:correct_ans_option2) or  quizze_params.key?(:correct_ans_option3) or  quizze_params.key?(:correct_ans_option5) )
        quizze_params[:correct_answer] = nil
      end
  		if @quiz.update_attributes(quizze_params)
        redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
      else
        render :action => "edit"
      end
    end
	end

	def show
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = [:answer]
        method_allowed = [:email, :question]
        send_data @quiz.user_quizzes.to_xls(:filename => 'user_quizzes', :methods => method_allowed, :only => only_columns)
      end
    end
  end

  def destroy
    if @quiz.destroy
      redirect_to admin_event_quizzes_path(:event_id => @quiz.event_id)
    end
  end

	protected

  def find_user_quizzes
    @user_quizzes = UserQuiz.where(:quizze_id => @quizzes.pluck(:id)) if @quizzes.present?
  end

  def find_quiz_wall
    @event = Event.find(params[:event_id])
    if params[:quiz_wall].present? and params[:quiz_wall] == "true" 
      @quizzes = @event.quizzes
    end
  end

  def find_groups
    @event = Event.find(params[:event_id])
    @groups = @event.invitee_groups
    @default_groups = []#@groups.where(:name => ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
    @other_groups = @groups.where('name NOT IN (?)', ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
  end
  
  def quiz_wall_present
    if params[:quiz_wall].present? and params[:quiz_wall] != 'true' or params[:quiz_wall].blank?
      authenticate_user!
      authorize_event_role
      find_features
    end
  end

  def quizze_params
    params.require(:quiz).permit!
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #(current_user.has_role? :db_manager) 
      redirect_to admin_dashboards_path
    end  
  end
end