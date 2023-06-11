class Admin::ClientsController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user

  def index
    if params[:feature].present?
      if params[:client_id].present? or (@clients.present? and @clients.count == 1)
        client_id = (@clients.count == 1) ? @clients.first.id : params[:client_id]
        return redirect_to admin_client_multi_lng_events_path(:client_id => params[:client_id]) if params[:feature] == "multi_lng_events"
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => "users", :redirect_page => "index", :telecaller => "true") if  params[:telecaller].present? and params[:telecaller] == "true" 
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => params[:feature]) if ["mobile_applications","users","manage_event_users","manage_moderator_users","marketing_apps"].exclude? params[:feature] and params[:redirect_page] != "new"
        return redirect_to new_admin_client_event_path(:client_id => client_id) if params[:feature] == "events" and params[:redirect_page] == "new"
        return redirect_to admin_client_mobile_applications_path(:client_id => client_id) if params[:feature] == "mobile_applications" and params[:redirect_page] != "new"
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => "mobile_applications",:new_marketing_app => "true") if params[:feature] == "mobile_applications" and params[:redirect_page] == "new"
        return redirect_to admin_client_users_path(:client_id => client_id) if params[:feature] == "users" and params[:role] == 'client_admin' and params[:redirect_page] == "index"
        return redirect_to new_admin_client_user_path(:client_id => client_id, :role => "client_admin") if params[:feature] == "users" and params[:role] == 'client_admin' and params[:redirect_page] != "index"
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => "users", :role => params[:role]) if params[:feature] == "users" and (params[:role] == 'event_admin' or params[:role] == 'moderator' or params[:role] == 'response_manager' or params[:role] == 'executive') and params[:redirect_page] != "index"
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => "users", :role => params[:role]) if params[:feature] == "users" and (params[:role] == 'db_manager') and params[:redirect_page] != "index" and params[:dashboard_client_level].blank?
        return redirect_to new_admin_client_user_path(:client_id => client_id, :feature => "users", :role => params[:role]) if params[:feature] == "users" and (params[:role] == 'db_manager')  or (params[:role] == 'client_response_manager')  and params[:redirect_page] != "index" and params[:dashboard_client_level].present?
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => "users", :role =>"telecaller") if params[:feature] == "users" and (params[:role] == 'telecaller') 
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => "users", :role => params[:role], :redirect_page => "index",:wall => "#{params[:wall].present?  ? params[:wall] : ""}") if params[:feature] == "users" and params[:role] == 'event_admin' or params[:role] == 'moderator' or params[:role] == 'response_manager' or params[:role] == 'executive' and params[:redirect_page] == "index"
        return redirect_to admin_client_events_path(:client_id => client_id, :feature => "users", :redirect_page => "index", :dashboard => "true") if  params[:feature] == "users" and params[:redirect_page] == "index" and params[:role].blank?
        return redirect_to admin_client_marketing_apps_path(:client_id => client_id) if params[:feature] == "marketing_apps" and params[:redirect_page] != "new"
        redirect_to new_admin_client_event_path(:client_id => client_id,:marketing_app => true) if params[:feature] == "marketing_apps"
      else
        @select = true
      end
    else
      @clients = Client.search(params, @clients) if params[:search].present?
      @clients = @clients.ordered.paginate(page: params[:page], per_page: 10)
    end
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    @user = (session[:licensee_user_id].present? ? current_user : ((current_user.has_role? :licensee_admin)? current_user : User.find(current_user.get_licensee)))
    @client.licensee_id = @user.id

    if @client.save and @user.present? 
      @user.add_role :licensee_admin, @client
      current_user.add_role :licensee_admin, @client if current_user.roles.pluck(:name).include? 'super_admin'
      redirect_to admin_client_events_path(:client_id => @client.id)
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if params[:status]
      @client.change_status(params[:status])
      redirect_to admin_clients_path(:page => params[:page])
    elsif params[:client]
      @client.update_attributes(client_params)
      redirect_to admin_clients_path
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @client.destroy
      redirect_to admin_clients_path
    end
  end

  protected

  def client_params
    params.require(:client).permit!
  end

end
