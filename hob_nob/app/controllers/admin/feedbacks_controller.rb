class Admin::FeedbacksController < ApplicationController
  layout 'admin'
  include ApplicationHelper
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :find_user_feedback, :only => [:new, :index]
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role, :except => [:index]
  before_filter :find_groups, :only => [:new, :create, :edit, :update]
    
  #before_action :find_feedback_form
  
	def index
    @feedbacks = Feedback.search(params,@feedbacks) if params[:search].present?
    if params[:feedback_form_id].present?
      @feedbacks = @feedbacks.where(event_id:params[:event_id],feedback_form_id:params[:feedback_form_id])
    else
      @feedbacks = @feedbacks.where(event_id:@event.id )#@feedbacks#.
    end
    #@feedbacks = @feedbacks.where(feedback_form_id: params[:feedback_form_id])#@feedbacks#.paginate(:page => params[:page], :per_page => 10) if params["format"] != "xls"
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = [:question, :option1, :option3, :option2, :option4, :option5, :option6, :option7, :option8, :option9, :option10, :option_type, :description, :sequence]
        method_allowed = []
        send_data @feedbacks.to_xls(:only => only_columns)
      end
    end
	end

	# def new
 #    @feedback = @event.feedbacks.build
 #    @feedback = @feedback_form.feedbacks.build
 #    @import = Import.new if params[:import].present?
	# end
  def new
    @feedback = Feedback.new
    @import = Import.new if params[:import].present?
  end

  def create
    if feedback_form_params[:feedback_form_id].present?
      @feedback = @event.feedbacks.build(feedback_params)
      @feedback.feedback_form_id = feedback_form_params[:feedback_form_id]
      if @feedback.save
        redirect_to admin_event_feedbacks_path(:event_id => @feedback.event_id,:feedback_form_id=> @feedback.feedback_form_id)
      else
        # session[:feed_que_error] = @feedback.errors[:question]
        # session[:feed_type_error] = @feedback.errors[:option_type]
        # session[:mandat_question] = @feedback.errors[:mandat_question]
        # session[:mandat_response] = @feedback.errors[:mandat_response]
        # redirect_to :back
        render :action => 'new'
      end    
    else 
      @feedback_form = FeedbackForm.new(feedback_form_params) 
      @feedback = @event.feedbacks.build(feedback_params)

      if @feedback.valid? and @feedback_form.valid?
        @feedback_form.save
        @feedback.feedback_form_id = @feedback_form.id
        @feedback.save
        #@feedback.update_column('feedback_form_id',@feedback_form.id)
        if params[:type].present?
          redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_engagement")
        else
          redirect_to admin_event_feedbacks_path(:event_id => @feedback.event_id,:feedback_form_id=> @feedback.feedback_form_id)
        end
      else
        if !@feedback_form.valid?    #do not delete this line
        end  
        render :action => 'new'
      end
    end  
  end

# def create
 #    @feedback = @event.feedbacks.build(feedback_params)
 #    @feedback.feedback_form_id = params[:feedback_form_id] if params[:feedback_form_id].present?
 #    if @feedback.save
 #      if params[:type].present?
 #        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_engagement")
 #      else
 #        redirect_to admin_event_feedback_form_feedbacks_path(:event_id => @feedback.event_id)
 #      end
 #    else
 #      render :action => 'new'
 #    end
	# end

	def edit
	end

	def update
	  if @feedback.update_attributes(feedback_params)
      redirect_to admin_event_feedbacks_path(:event_id => @feedback.event_id,:feedback_form_id=> @feedback.feedback_form_id)
    else
      render :action => "edit"
    end
	end

  def show
    respond_to do |format|
      format.html  
      format.xls do
        #@feedback = Feedback.where(:id => params[:id])
        #only_columns = [:question]
        #method_allowed = [:option1_percentage,:option2_percentage,:option3_percentage,:option4_percentage,:option5_percentage,:option6_percentage,:option7_percentage,:option8_percentage,:option9_percentage,:option10_percentage]
        only_columns = [:answer]
        method_allowed = [:question, :email]
        send_data @feedback.user_feedbacks.to_xls(:methods => method_allowed, :only => only_columns)
      end  
    end
  end

  def destroy
    if @feedback.destroy
      redirect_to admin_event_feedbacks_path(:event_id => @feedback.event_id,:feedback_form_id=>@feedback.feedback_form_id)
    end
  end

	protected

  def find_groups
    @event = Event.find(params[:event_id])
    @groups = @event.invitee_groups
    @default_groups = []#@groups.where(:name => ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
    @other_groups = @groups.where('name NOT IN (?)', ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
  end

  def find_user_feedback
    @feedback_ids = Feedback.where(:feedback_form_id=>params[:feedback_form_id])
    @user_feedbacks = UserFeedback.where(:feedback_id => @feedback_ids.pluck(:id)) if @feedback_ids.present?
    #@user_feedbacks = UserFeedback.where(:feedback_id => @feedbacks.pluck(:id)) if @feedbacks.present?
  end

  def find_feedback_form
    @feedback_form = FeedbackForm.find(params[:feedback_form_id])
  end

  def feedback_params
    params.require(:feedback).permit!
  end
  
  def feedback_form_params
    params.require(:feedback_form).permit!
  end

  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #current_user.has_role? :db_manager 
      redirect_to admin_prohibited_accesses_path
      #redirect_to admin_dashboards_path
    end  
  end
end
