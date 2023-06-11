class Admin::ManageUsersController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user
  before_filter :find_client, :only => [:index, :new, :create, :new, :edit, :update, :add_role_to_user]

  def index
    @source = @event.present? ? @event : @client
    if current_user.has_role? :licensee_admin
      @role = Role.where(:resource_type => nil, :resource_id => nil, :name => 'licensee_admin').first
    elsif @source.present?
      @role = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and users.id = ?', @source.class.name, @source.id, current_user.id).uniq.last
      @role = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? ', @source.class.name, @source.id).uniq.last if current_user.has_role? :event_admin
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

end
