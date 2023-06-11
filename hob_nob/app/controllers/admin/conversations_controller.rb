class Admin::ConversationsController < ApplicationController 
  layout 'admin'
  skip_before_filter :authenticate_user, :authorize_event_role, :find_features, :find_likes_and_comments, :only => [:index]
  skip_before_action :load_filter, :only => [:index] 
  before_filter :authenticate_user, :authorize_event_role, :find_features, :find_likes_and_comments, :except => [:index]
  before_filter :check_user_role, :except => [:index]
  before_filter :conversation_wall_present, :only => [:index]
  before_filter :find_conversation_wall, :only => :index
  before_filter :check_for_access, :only => [:index]

  def index
    @conversations = @conversations.paginate(page: params[:page], per_page: 10) if params["format"] != "xls" and params[:conversations_wall].blank?
    @conversations = Conversation.get_conversations_by_status(@conversations, params[:type]) if params[:type].present? and params[:type] != 'dashboard_new'
    Conversation.set_auto_approve(params[:auto_approve],@event) if params[:auto_approve].present?
    respond_to do |format|
      @conversations = @conversations.where(:on_wall => "yes",:status => "approved").last(12) if params[:conversations_wall].present?
      format.html{render :layout => false} if params[:conversations_wall].present?
      format.html if params[:conversations_wall].blank?
      format.xls do
        only_columns = []
        method_allowed = [:post_id, :timestamp, :email_id, :invitee_first_name, :invitee_last_name, :conversation, :image_url, :Status, :like_count, :comment, :commented_user_email, :commented_user_name]
        object = Conversation.get_export_object(@conversations).flatten
        send_data object.to_xls(:only => only_columns, :methods => method_allowed)
      end
    end
  end

  def new
    @conversation = @event.conversations.build
    @import = Import.new if params[:import].present?
    redirect_to admin_event_conversations_path(:event_id => params[:event_id]) if @import.blank?
  end

  def create
    @conversation = @event.conversations.build(conversation_params)
    if @conversation.save
      redirect_to admin_event_conversations_path(:event_id => @conversation.event_id)
    else
      render :action => 'new'
    end
  end

  def edit
  end
      
  def update
    if params[:status].present? or params[:on_wall].present?
      @conversation.update_column(:on_wall, params[:on_wall]) if params[:on_wall].present?
      @conversation.perform_conversation(params[:status]) if params[:status].present?
      redirect_to admin_event_conversations_path(:event_id => @conversation.event_id,:page => params[:page])
    elsif @conversation.update_attributes(conversation_params)
      redirect_to admin_event_conversations_path(:event_id => @conversation.event_id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @conversation.destroy
      redirect_to admin_event_conversations_path(:event_id => @conversation.event_id)
    end
  end

  protected

  def find_likes_and_comments
    @conversations = @event.conversations
    @likes = Like.where(:likable_id => @conversations.pluck(:id), :likable_type => 'Conversation')
    @comments = Comment.where(:commentable_id => @conversations.pluck(:id), :commentable_type => 'Conversation')
  end

  def find_conversation_wall
    if params[:conversations_wall].present?
      @event = Event.find(params[:event_id])
      @conversations = @event.conversations
    end
  end

  def conversation_wall_present
    if params[:conversations_wall].present? and params[:conversations_wall] != 'true' or params[:conversations_wall].blank?
      authenticate_user!
      authorize_event_role
      find_features
      find_likes_and_comments
    end
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #current_user.has_role? :db_manager 
      redirect_to admin_dashboards_path
    end  
  end

  def conversation_params
    params.require(:conversation).permit!
  end
end
