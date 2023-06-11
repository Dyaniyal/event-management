class Admin::CustomPage1sController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :check_user_role

  def index
    if @event.present? and @event.custom_page1s.present?
      if params[:from] == "microsites"
        redirect_to edit_admin_event_custom_page1_path(:event_id => params[:event_id],:id => @event.custom_page1s.last.id, :from => "microsites")
      else
        redirect_to edit_admin_event_custom_page1_path(:event_id => params[:event_id],:id => @event.custom_page1s.last.id)
      end
    else
      redirect_to new_admin_event_custom_page1_path(:event_id => params[:event_id])
    end
  end

  def new
    if @event.present? and @event.custom_page1s.present?
      redirect_to edit_admin_event_custom_page1_path(:event_id => params[:event_id],:id => @event.custom_page1s.last.id)
    else
      @custom_page1 = @event.custom_page1s.build
    end
  end

  def create
    @custom_page1 = @event.custom_page1s.build(custom_page_params)
    if @custom_page1.save
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
    if @custom_page1.update_attributes(custom_page_params)
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
    if @custom_page1.destroy
      if params[:from] == "microsites"
        redirect_to admin_event_microsite_path(:event_id => @event.id,:id => @event.microsite.id,  :type => "show_content")
      else
        redirect_to admin_event_custom_page1s_path(:event_id => @custom_page1.event_id)
      end
    end
  end

  protected

  def custom_page_params
    params.require(:custom_page1).permit!
  end
  def check_user_role
    if (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])) #current_user.has_role? :db_manager 
      redirect_to admin_dashboards_path
    end  
  end
end