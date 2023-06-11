class Admin::MicrositeMenusController < ApplicationController
    layout 'admin'

  before_filter :authenticate_user, :authorize_event_role, :find_microsite

  def index
  end

  def create
    if @microsite.update_microsite_features_from_menu(microsite_params)
      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id)
    else
      render :action => 'index'
    end
  end

  def update
    @event.microsite.update_column(:menu_saved, "true")
    if params[:status].present?
      @microsite_feature.set_status(params[:status])
      redirect_to admin_event_microsite_microsite_menus_path(:event_id => @event.id, :microsite_id => @microsite.id)
    end
  end

  def destroy
    if @microsite_feature.destroy
      redirect_to admin_event_microsite_microsite_menus_path(:event_id => @event.id, :microsite_id => @microsite.id)
    end
  end
  
  protected
  def find_microsite
    @microsite = Microsite.find(params[:microsite_id])
  end

  def microsite_params
    params.require(:microsite).permit!
  end 
end