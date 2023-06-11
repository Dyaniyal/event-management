class Admin::InviteeGroupsController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_user_role, :except => [:index]
    
  def index
  end

  def new
    @invitee_group = @event.invitee_groups.new
    @invitees = @event.invitees
  end

  def create
    @invitee_group = @event.invitee_groups.new(invitee_group_params)
    @invitee_group.invitee_ids = @event.invitees.map{|n| n.id.to_s} if @invitee_group.invitee_ids.include? 'select_all'
    if @invitee_group.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        redirect_to admin_event_invitee_groups_path(:event_id => @invitee_group.event_id)
      end
    else
      @invitees = @event.invitees
      render :action => 'new'
    end
  end

  def edit
  	@invitees = @event.invitees
    redirect_to admin_event_invitee_groups_path(:event_id => @invitee_group.event_id) if @invitee_group.default_logical_group?
  end

  def update
    params[:invitee_group].merge!('invitee_ids' => @event.invitees.map{|n| n.id.to_s}) if params[:invitee_group][:invitee_ids].include? 'select_all'
    if @invitee_group.update_attributes(invitee_group_params)
      redirect_to admin_event_invitee_groups_path(:event_id => @invitee_group.event_id)
    else
    	@invitees = @event.invitees
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @invitee_group.destroy
      redirect_to admin_event_invitee_groups_path(:event_id => @invitee_group.event_id)
    end
  end

  protected
  def invitee_group_params
  	params["invitee_group"]["invitee_ids"] = params["invitee_group"]["invitee_ids"].reject(&:empty?) if  (params["invitee_group"].present? and params["invitee_group"]["invitee_ids"].present?)
    params.require(:invitee_group).permit!
  end
  def check_user_role
    if (!current_user.has_role? :db_manager) 
      redirect_to admin_dashboards_path
    end  
  end
end
