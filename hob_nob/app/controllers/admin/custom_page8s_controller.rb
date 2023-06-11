class Admin::CustomPage8sController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_user_role

  def index
    if @event.present? and @event.custom_page8s.present?
      if params[:from] == "microsites"
        redirect_to edit_admin_event_custom_page8_path(:event_id => params[:event_id],:id => @event.custom_page8s.last.id, :from => "microsites")
      else
        redirect_to edit_admin_event_custom_page8_path(:event_id => params[:event_id],:id => @event.custom_page8s.last.id)
      end
    else
      redirect_to new_admin_event_custom_page8_path(:event_id => params[:event_id])
    end
  end

  def new
    if @event.present? and @event.custom_page8s.present?
      redirect_to edit_admin_event_custom_page8_path(:event_id => params[:event_id],:id => @event.custom_page8s.last.id)
    else
      @custom_page8 = @event.custom_page8s.build
    end
  end

  def create
    @custom_page8 = @event.custom_page8s.build(custom_page_params)
    if @custom_page8.save
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id,:id => @event.microsite.id,  :type => "show_content")
      else
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @custom_page8.update_attributes(custom_page_params)
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id,:id => @event.microsite.id,  :type => "show_content")
      else
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      end
    else
      render :action => "edit"
    end
  end

  def show
    render :layout => false
  end

  def destroy
    if @custom_page8.destroy
      redirect_to admin_event_custom_page8s_path(:event_id => @custom_page8.event_id)
    end
  end

  protected

  def custom_page_params
    params.require(:custom_page8).permit!
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]))
      redirect_to admin_dashboards_path
    end  
  end
end