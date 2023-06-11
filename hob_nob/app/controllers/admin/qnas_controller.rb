class Admin::QnasController < ApplicationController
  layout 'admin'

  skip_before_action :load_filter, only: [:index, :show]
  before_filter :authenticate_user, :authorize_event_role, :check_user_role, except: [:index, :show]
  before_filter :find_event, only: :show
  before_filter :find_features, except: :index
  before_filter :qna_wall_present, :find_qna_wall, :check_for_access, only: :index

	def index
    if params[:auto_approve].present?
      Qna.set_auto_approve(params[:auto_approve],@event)
    end
    if params[:qnas_wall].present?
        @qnas = @qnas.where(:on_wall => "yes")
        render :layout => false
    else
      @qnas = Qna.search(params, @qnas) if params[:search].present?
      @qnas = @qnas.paginate(page: params[:page], per_page: 1000) if params["format"] != "xls"
      respond_to do |format|
        format.html  
        format.xls do
          only_columns = []
          method_allowed = [:Timestamp, :email_id, :first_name, :last_name, :question_ask, :speaker_name, :qna_status]
          send_data @qnas.to_xls(:only => only_columns, :methods => method_allowed)
        end
      end
    end  
  end

	def new
	@qna = @event.qnas.build
    @panels = Panel.where(:event_id => params[:event_id])
    @import = Import.new if params[:import].present?
    # redirect_to admin_event_qnas_path(:event_id => params[:event_id]) if @import.blank?
	end

	def create
    if params[:qna].present? and params[:qna][:sender_email].present?
      params[:qna].merge!(:sender_email => params[:qna][:sender_email].split('(').last.split(')').last) if params[:qna][:sender_email].present?
      @invitee = Invitee.where(event_id: params[:event_id], email: params[:qna][:sender_email]).last
      params[:qna].merge!(:sender_id => @invitee.id) if @invitee.present?
    end
		@qna = @event.qnas.build(qna_params)
    if @qna.save
      redirect_to admin_event_qnas_path(:event_id => @qna.event_id)
    else
      @panels = Panel.where(:event_id => params[:event_id])
      @qna.errors.add :sender_email, 'This field is required' if params[:qna][:sender_email].blank?
      @qna.errors.add :sender_email, 'Invalid email ID' if @qna.errors['sender_id'].present?
      render :action => 'new'
    end
	end

	def edit
    @panels = Panel.where(:event_id => params[:event_id])
	end

	def update
    if params[:status].present? or params[:on_wall].present? or params[:anonymous_on_wall].present?
      @qna.update_column(:anonymous_on_wall, params[:anonymous_on_wall]) if params[:anonymous_on_wall].present?
      @qna.update_column(:on_wall, params[:on_wall]) if params[:on_wall].present?
      @qna.change_status(params[:status]) if params[:status].present?
      @qna.update_column(:wall_answer, nil) if @qna.on_wall == "no"
      redirect_to admin_event_qnas_path(:event_id => @qna.event_id, :page => params[:page])
    elsif params[:wall_answer].present? 
      @qna.update_column(:wall_answer, params[:wall_answer]) if params[:wall_answer].present?
      redirect_to admin_event_qnas_path(:event_id => @qna.event_id, :page => params[:page])  
    else
      if params[:qna_change_status].present?
        @qna.status = params[:qna_change_status]
        @qna.save 
        redirect_to admin_event_qnas_path(:event_id => @qna.event_id)
      else
        @panels = Panel.where(:event_id => params[:event_id])
        @qna.update_attributes(qna_params) ? (redirect_to admin_event_qnas_path(:event_id => @qna.event_id)) : (render :action => "edit")
      end
    end
  end

  def show
    if params[:wall_answer].present? or params[:on_wall].present?
      @qna.update_column(:wall_answer, params[:wall_answer]) if params[:wall_answer].present?
      redirect_to admin_event_qnas_path(:event_id => @qna.event_id, :page => params[:page], :qnas_wall => true)
    end
  end

  def destroy
    if @qna.destroy
      redirect_to admin_event_qnas_path(:event_id => @qna.event_id)
    end
  end

  protected

  def find_event
    @event = Event.find(params[:event_id]) if params[:event_id].present?
  end

  def find_qna_wall
    if params[:qnas_wall].present?
      @event = Event.find(params[:event_id])
      @qnas = @event.qnas
    end
  end

  def qna_wall_present
    if params[:qnas_wall].present? and params[:qnas_wall] != 'true' or params[:qnas_wall].blank?
      authenticate_user!
      authorize_event_role
      find_features
    end
  end
  
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #current_user.has_role? :db_manager 
      redirect_to admin_dashboards_path
    end  
  end

  def qna_params
    params.require(:qna).permit!
  end
end
