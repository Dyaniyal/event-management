class Admin::ManageInviteeFieldsController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  #before_filter :check_user_role, :except => [:index]
  before_filter :authenticate_user, :authorize_event_role, :find_features
  

  def index
    if @event.manage_invitee_fields.present?
      redirect_to edit_admin_event_manage_invitee_field_path(:event_id => @event.id,:id => @event.manage_invitee_fields.last.id)
    else
      redirect_to new_admin_event_manage_invitee_field_path(:event_id => @event.id)
    end
  end

  def new
    if @event.manage_invitee_fields.present?
      redirect_to edit_admin_event_manage_invitee_field_path(:event_id => @event.id,:id => @event.manage_invitee_fields.last.id)
    else
      @manage_invitee_field = @event.manage_invitee_fields.build
    end
  end

  def create
    @manage_invitee_field = @event.manage_invitee_fields.build(manage_invitee_field_params)
    if @manage_invitee_field.save
      redirect_to admin_event_invitees_path(:event_id => @manage_invitee_field.event_id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @manage_invitee_field.update_attributes(manage_invitee_field_params)
      redirect_to admin_event_invitees_path(:event_id => @manage_invitee_field.event_id)
    else
      render :action => "edit"
    end
  end

  def show
    
  end

  def destroy
    
  end

  protected

  def check_user_role
    if (!current_user.has_role_for_event?("db_manager", @event.id)) and (!current_user.has_role_for_event?("licensee_admin", @event.id)) #(!current_user.has_role? :db_manager) and (!current_user.has_role? :licensee_admin)
      redirect_to admin_dashboards_path
    end  
  end
  def manage_invitee_field_params
    if params[:manage_invitee_field].present?
      params.require(:manage_invitee_field).permit!
    else
      params["manage_invitee_field"] = {'first_name' => 'false', 'last_name' => 'false', 'email' => 'false', 'company_name' => 'false', 'designation' => 'false'}
    end
  end

end
