class Admin::EventGroupsController < ApplicationController
  layout 'admin'

  # load_and_authorize_resource
  before_filter :authenticate_user
   before_filter :authorize_event_role, :except => [:index,:new,:create,:edit,:update,:show,:destroy]#, :if => Proc.new{params[:event_id].present?}
  before_filter :authorize_client_role, :find_client_association#, :only => [:index, :show, :edit, :update], :if => Proc.new{params[:client_id].present?}

  def index
    @event_groups = EventGroup.search(params, @event_groups) if params[:search].present?
    @event_groups = @event_groups.paginate(page: params[:page], per_page: 10)
  end
  def new
    @event_group = @client.event_groups.build
  end
  def create
     @event_group = @client.event_groups.new(event_groups_params)
    if @event_group.save
      redirect_to admin_client_event_groups_path(:client_id => @event_group.client_id)
    else
      render :action => 'new'
    end
  end
  def edit
    
  end
  def update
    if @event_group.update_attributes(event_groups_params)
      redirect_to admin_client_event_groups_path(:client_id => @event_group.client_id)
    else
      render :action => 'edit'
    end
  end
  def destroy
    if @event_group.destroy
      redirect_to admin_client_event_groups_path(:client_id => @event_group.client_id)
    end 
  end
  def show
    
  end

  protected
    def event_groups_params
      params.require(:event_group).permit!
    end  
end
