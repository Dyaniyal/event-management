class Admin::ProfilesController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user
  before_filter :set_url_history, :except => :update

  # def index
  #   @users = User.unscoped.where(:license => true).paginate(page: params[:page], per_page: 10)#.order('created_at DESC')
  #   @users = User.search(params,@users, user_type = "Licensee") if params[:search].present?
  # end   

  # def new
  #   @user = User.new
  # end

  # def create 
  #   @user = User.new(user_params)
  #   if @user.save
  #     @user.change_status_for_super_admin
  #     redirect_to admin_users_path
  #   else
  #     render :action => 'new'
  #   end
  # end

  def edit
    @user = User.unscoped.find(params[:id])
  end

  def update
    @user = User.unscoped.find(params[:id])
    user_errors = @user.check_currect_password(params[:user])
    #user_errors and @user.update_attributes(user_params.except(:current_password))
    if @user.update_attributes(user_params.except(:current_password))
      # url = session[:url_history].pop
      # redirect_to session[:url_history].pop if url.present?
      redirect_to admin_dashboards_path #if url.blank?
    else
      render :action => "edit"
    end
  end


  def show
    @user = User.unscoped.find(params[:id])
    @clients = Client.with_roles(@user.roles.pluck(:name), @user)
    @event_count = @clients.map{|c| c.events.count}.sum
  end

  def destroy
    @user = User.unscoped.find(params[:id])
    if @user.destroy
      redirect_to admin_users_path
    end
  end

  protected

  def user_params
    params.require(:user).permit!
  end

end
