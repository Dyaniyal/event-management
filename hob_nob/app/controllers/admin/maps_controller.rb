class Admin::MapsController < ApplicationController
	layout 'admin'
  load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  
  def index
    @maps = Map.search(params, @maps) 
  end

  
  def new
    if @event.map.nil?
      @map = @event.build_map
    else
      redirect_to edit_admin_event_map_path(:event_id => @event.id, :id => @event.map.id)
    end  
  end

  def create
    @map = @event.build_map(map_params)
    if @map.save
      redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id,:type => "show_content")
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @map.update_attributes(map_params)
      redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id, :type => "show_content")
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @map.destroy
      redirect_to admin_event_maps_path(:event_id => @map.event_id)
    end
  end

  protected
    def map_params
      params.require(:map).permit(:map_id, :app_id, :event_id)
    end
end
