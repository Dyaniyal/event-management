class Admin::UsersController < ApplicationController
  layout 'admin'

  load_and_authorize_resource
  before_filter :authenticate_user
  before_filter :find_client, :only => [:index, :new, :create, :new, :edit, :update, :add_role_to_user]

  def index
    @source = @event.present? ? @event : @client
    if current_user.has_role? :licensee_admin
      @role = Role.where(:resource_type => nil, :resource_id => nil, :name => 'licensee_admin').first
    elsif @source.present?
      @role = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', @source.class.name, @source.id, current_user.id).uniq.last
      #@role = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? ', @source.class.name, @source.id).uniq.last if current_user.has_role? :event_admin
      @role = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', @client.class.name, @client.id, current_user.id).uniq.last if @role.blank? and @client.present?
    end
    if @role.present?
      if @source.present?
        @users = User.joins(:roles).where('roles.resource_type = ? and resource_id = ? and roles.name NOT IN (?)', @source.class.name, @source.id, Role.not_manage_user_dropdown(@role.name)).uniq if @source.present?
      else
        @users = User.where(:licensee_id => current_user.id)
      end  
        @users = User.search(params, @users, user_type = "Manage_user") if params[:search].present?
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def new
    if params[:email].present?
      @email = params[:email].split('(').last.split(')').first
      name = params[:email].split('(').first
      #@user = User.find_or_initialize_by(:email => @email, :licensee_id => [current_user.get_licensee])
      #@user.first_name = name
      @user = User.where(:email => @email, :licensee_id => [current_user.get_licensee]).first rescue []
      if @user.present?
        @user = User.find_or_initialize_by(:email => @email, :licensee_id => [current_user.get_licensee])
        @user.first_name = @user.first_name rescue nil
      else
        @user = User.new
        @user.licensee_id = current_user.get_licensee
      end
      @role, @url = params[:role], params[:redirect_url]
    end
    respond_to do |format|
      format.js{}
      format.html{}
    end
  end

  def create
    @user = User.find_or_initialize_by(:email => params[:user][:email], :licensee_id => current_user.get_licensee)
    @user.password = params[:user][:password] if @user.id.blank?
    @user.first_name = params[:user][:first_name] if params[:user][:first_name].present?
    @user.last_name = params[:user][:last_name] if params[:user][:last_name].present?
    @user.status = "active"
    if @user.save
      add_role_to_user
      @user.update_column(:licensee_id, current_user.get_licensee)
      if params[:page_id] == "event_show_card"
        redirect_to admin_client_event_path(:id => @event.id, :client_id => @client.id)
      elsif params[:event_id].present?
        redirect_to admin_event_users_path(:event_id => @event.id, :role => params["get_role"])
      else
        redirect_to admin_client_users_path(:client_id => @client.id)
      end
      #redirect_to params["redirect_url"]
    else
      @url = params["redirect_url"]
      render :action => 'new'
    end
  end

  
  def show
  end
  
  def edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      add_role_to_user
      if params[:page_id] == "event_show_card"
        redirect_to admin_client_event_path(:id => @event.id, :client_id => @client.id)
      elsif params[:event_id].present?
        redirect_to admin_event_users_path(:event_id => @event.id, :role => params["get_role"])
      else
        redirect_to admin_event_users_path(:event_id => params[:events_id], :role => params["get_role"]) if params[:get_role] == "all" and params[:events_id].present?
        redirect_to admin_client_users_path(:client_id => @client.id) if params[:get_role] != "all"
      end
    else
      @url = params["redirect_url"]
      render :action => 'edit'
    end
  end

  def destroy
    if params[:delete_role].present?
      if params[:event_id].present?
        event = Event.find_by_id(params[:event_id])
        @user.roles.delete(@user.roles.where("resource_id = ? and resource_type = ?", event.id, "Event")) rescue nil
        @user.roles.where(resource_id: nil, resource_type: nil, name: "event_admin").delete_all if @user.roles.where(name: "event_admin").length == 1 rescue nil 
        @user.roles.where(resource_id: nil, resource_type: nil, name: "moderator").delete_all if @user.roles.where(name: "moderator").length == 1  rescue nil 
        redirect_to admin_event_users_path(:event_id => event.id, :role => params["get_role"])
      elsif params[:client_id].present?
        client = Client.find_by_id(params[:client_id])
        @user.roles.delete(@user.roles.where("resource_id = ? and resource_type = ?", client.id, "Client")) rescue nil
        @user.roles.where(resource_id: nil, resource_type: nil, name: "client_admin").delete_all if @user.roles.where(name: "client_admin").length == 1 rescue nil
        redirect_to admin_event_users_path(:event_id => params[:events_id], :role => params["get_role"]) if params[:get_role] == "all" and params[:events_id].present?
        redirect_to admin_client_users_path(:client_id => client.id) if params[:get_role] != "all"
      end
    else
      if @user.destroy
        redirect_to admin_users_path
      end
    end  
  end

  # def check_email_existance
  #   if params[:email].present?
  #     email = params[:email].split('(').last.split(')').first
  #     name = params[:email].split('(').first
  #     @user = User.find_or_initialize_by(:email => email, :licensee_id => [current_user.get_licensee])
  #     @user.first_name = name
  #     @role, @url = params[:role], params[:redirect_url]
  #   end
  #   respond_to do |format|
  #     format.js{}
  #     format.html{}
  #   end
  # end

  protected

  def find_client
    if params[:client_id].present?
      @client = Client.find(params[:client_id])
    elsif params[:event_id].present?
      @event = Event.find(params[:event_id])
      @client = @event.client
    end
    @source = params[:event_id].present? ? @event : @client
  end

  def add_role_to_user
    if @event.present? and params[:user][:role_type].present?
      @user.assign_role_to_user(params[:user][:role_type], @event)
    elsif @client.present? and params[:user][:role_type].present? and !@event.present?
      @user.assign_role_to_user(params[:user][:role_type], @client)
    end
  end

  def user_params
    params.require(:user).permit!
  end
end
