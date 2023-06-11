class Admin::MicrositesController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user
  before_filter :find_event#, :only => [:index, :new, :create, :edit]

  def index
  end

  def new
    if @event.microsite.nil?
      @microsite = @event.build_microsite
    else
      redirect_to edit_admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id)
    end  
  end

  def create
    @microsite = @event.build_microsite(microsite_params)
    if @microsite.save
      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @microsite.id)
    else
      render :action => 'new'
    end
  end

  def edit
    @microsite = Microsite.find(params[:id])
  end

  def update
    @microsite = Microsite.find(params[:id])
    if params[:get] == "registrations"
      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id, :type => "show_content")
    end 
    if params[:enable].present? or params[:disable].present?
      @microsite.add_single_microsite_features(params) if params[:enable].present?
      @microsite.remove_single_microsite_features(params) if params[:disable].present?
      respond_to{|format| format.js{} }
    elsif @microsite.update_attributes(microsite_params)
      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @microsite.id)
    else
      render :action => "edit"
    end
  end

  def show
    @microsite = Microsite.find(params[:id])
  end

  def destroy
    @microsite = Microsite.find(params[:id])
    if @microsite.destroy
      redirect_to admin_event_microsites_path
    end
  end

  protected
  
  def microsite_params
    params.require(:microsite).permit!
  end

  def find_event
    @event = Event.find(params[:event_id])
  end
end

