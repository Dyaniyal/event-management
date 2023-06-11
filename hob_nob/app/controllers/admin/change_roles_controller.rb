class Admin::ChangeRolesController < ApplicationController
  layout 'admin'
  before_filter :authenticate_user
  before_filter :check_roles_count

  def index
    
  end  

  def new
    
  end
  def create
    session[:current_user_role] = params[:role]
    if session[:current_user_role] =="telecaller" and current_user.telecaller_groups.count == 1
      telecaller_group = current_user.telecaller_groups.first
      redirect_to admin_event_telecaller_dashboards_path(:event_id => telecaller_group.event_id, :user_id => telecaller_group.user_id)
    else 
      (params[:previous_url].include?("/users/sign_in") or params[:previous_url].include?("/admin/prohibited_accesses") or params[:previous_url].include?("/telecaller_dashboards")) ? (redirect_to admin_dashboards_path) : (redirect_to params[:previous_url])
    end
  end

  protected

  def check_roles_count
    if User.current.roles.pluck(:name).uniq.count <= 1
      session[:current_user_role] = User.current.roles.pluck(:name).uniq.first
      if session[:current_user_role] =="telecaller" and current_user.telecaller_groups.count == 1 
        telecaller_group = current_user.telecaller_groups.first
        redirect_to admin_event_telecaller_dashboards_path(:event_id => telecaller_group.event_id, :user_id => telecaller_group.user_id)
      else
        redirect_to admin_dashboards_path
      end  
    end
  end
end
