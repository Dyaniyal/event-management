class Admin::MicrositeLookAndFeelsController < ApplicationController
	layout 'admin'
	before_filter :authenticate_user, :authorize_event_role, :find_microsite
	
	def index
  end

  def new
    if @microsite.microsite_look_and_feel.nil?
      @microsite_look_and_feel = @microsite.build_microsite_look_and_feel
    else
      redirect_to edit_admin_event_microsite_microsite_look_and_feel_path(:event_id => @event.id, :microsite_id => @event.microsite.id, :id => @microsite.microsite_look_and_feel.id)
    end 
  end

  def create
    @microsite_look_and_feel = @microsite.build_microsite_look_and_feel(microsite_look_and_feel_params)
    if @microsite_look_and_feel.save
      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id)
    else
      render :action => 'new'
    end
  end

  def edit
    @microsite_look_and_feel = MicrositeLookAndFeel.find(params[:id])
  end

  def update
    @microsite_look_and_feel = MicrositeLookAndFeel.find(params[:id])
    if (params[:remove_image].present? and params[:remove_image] == "true")
      @microsite_look_and_feel.update_attribute(:banner_image, nil) if (@microsite_look_and_feel.banner_image.present? and (params[:banner_image].present? and params[:banner_image] == "true"))
      @microsite_look_and_feel.update_attribute(:logo, nil) if (@microsite_look_and_feel.logo_file_name.present? and (params[:logo].present? and params[:logo] == "true"))
      redirect_to edit_admin_event_microsite_microsite_look_and_feel_path(:event_id => @event.id, :microsite_id => @microsite.id)
    elsif @microsite_look_and_feel.update_attributes(microsite_look_and_feel_params)
      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id)
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @microsite_look_and_feel.destroy
      redirect_to admin_event_microsite_path(:event_id => @event.id, :id => @event.microsite.id)
    end
  end

  protected
  def find_microsite
    @microsite = Microsite.find(params[:microsite_id])
  end

  def microsite_look_and_feel_params
    params.require(:microsite_look_and_feel).permit!
  end
end