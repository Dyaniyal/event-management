class Admin::RolesController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user
  before_filter :find_role, :except => [:index,:new,:create]

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end
  
  def create
    user = User.find(params[:user_id])
    case params[:resource_type]
    when 'client'
      @resource = Client.find(params[:resource_id])
    when 'event'
      @resource = Event.find(params[:resource_id])
    end
    respond_to do |format|
      if user.present? and @resource.present? and params[:role_type].present?
        user.add_role params[:role_type]
        user.add_role params[:role_type], @resource
      end
      format.html{redirect_to params[:link]}
      format.js { render :js => "window.location.href = '#{admin_users_path}'" }
    end
  end


  def edit
  end

  def update
    if @role.update_attributes(role_params)
      redirect_to admin_roles_path
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @role.destroy
      redirect_to admin_roles_path
    end
  end

  protected

  # def role_params
  #   params.require(:role).permit!
  # end
  
end
