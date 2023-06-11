class Admin::NotificationsController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :find_groups, :only => [:new, :create, :edit, :update]
  before_filter :check_user_role, :except => [:index]
  before_filter :get_associated_data, :only => [:edit,:update]
  def index
    @notifications = @notifications.paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @notification = @event.notifications.build
  end


  def create
    @notification = @event.notifications.build(notification_params)
    @notification.set_time(params["notification"]["push_datetime"], params["notification"]["push_time_hour"], params["notification"]["push_time_minute"], params["notification"]["push_time_am"]) if params["notification"]["push_time_hour"].present?
    @notification.sender_id = current_user.id
    if @notification.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_engagement")
      else
        redirect_to admin_event_notifications_path(:event_id => @notification.event_id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @notification.update_attributes(notification_params)
      @notification.set_time(params["notification"]["push_datetime"], params["notification"]["push_time_hour"], params["notification"]["push_time_minute"], params["notification"]["push_time_am"]) if params["notification"]["push_time_hour"].present?
      @notification.save
      redirect_to admin_event_notifications_path(:event_id => @notification.event_id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @notification.destroy
      redirect_to admin_event_notifications_path(:event_id => @notification.event_id)
    end
  end

  protected

  def notification_params
    params["notification"]["group_ids"] = params["notification"]["group_ids"].reject(&:empty?) if  (params["notification"].present? and params["notification"]["group_ids"].present?)
    params.require(:notification).permit!
  end

  def find_groups
    @groups = @event.invitee_groups
    @default_groups = @groups.where(:name => ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
    @other_groups = @groups.where('name NOT IN (?)', ['No Polls taken', 'No Feedback given', 'No Quiz taken', 'No Q&A Participation', 'No Participation in Conversations', 'No Favorites added'])
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]))
      redirect_to admin_dashboards_path
    end  
  end
  def get_associated_data
    if @notification.action.present?
      feature_name = @notification.action.downcase.pluralize if @notification.action != "E-Kit"
      feature_name = "e_kits" if @notification.action == "E-Kit"
      if ["speakers","polls","quizzes","agendas","e_kits","feedbacks"].include? feature_name
        @data = instance_variable_set("@"+feature_name, @event.send(feature_name))
        if feature_name == "feedbacks"
          feedback_form_ids = @data.pluck(:feedback_form_id).uniq.compact
          if feedback_form_ids.present?
            @data = FeedbackForm.where("id IN (?) and status = ? ",feedback_form_ids,"active")
          end
        elsif feature_name == "polls"
          @associated_data = @data.where(:status => "activate")
        elsif feature_name == "quizzes"
          @associated_data = @data.where(:status => "activate")
        end
      end
    end
  end
end
