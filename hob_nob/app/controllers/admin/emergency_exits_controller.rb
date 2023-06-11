class Admin::EmergencyExitsController < ApplicationController

layout 'admin'

before_filter :authenticate_user, :authorize_event_role, :find_features

  def index
  end

  def new
    if @event.emergency_exit.nil?
      @emergency_exit = @event.build_emergency_exit
    else
      redirect_to edit_admin_event_emergency_exit_path(:event_id => @event.id, :id => @event.emergency_exit.id)
    end  
  end

  def create
    @emergency_exit = @event.build_emergency_exit(emergency_exit_params)
    if @emergency_exit.save
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
      else
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @emergency_exit.update_attributes(emergency_exit_params)
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
      else      
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id,:type => "show_content")
      end
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @emergency_exit.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_emergency_exits_path(:event_id => @emergency_exit.event_id, :from => "microsites")
      else
        redirect_to admin_event_emergency_exits_path(:event_id => @emergency_exit.event_id)
      end
    end
  end

  protected

  def emergency_exit_params
    params.require(:emergency_exit).permit!
  end

end
