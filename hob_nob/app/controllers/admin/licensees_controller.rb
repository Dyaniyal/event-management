class Admin::LicenseesController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user
  before_filter :authenticate_super_admin
  before_filter :set_current_licensee, :only => [:show]

  def index
    @licensees = User.unscoped.where(:license => true).paginate(page: params[:page], per_page: 10).check_deleted_record.order('created_at DESC')
    @licensees = User.search(params,@licensees, user_type = "Licensee") if params[:search].present?
  end   

  def new
    @licensee = User.new
  end

  def create 
    @licensee = User.new(licensee_params)
    if @licensee.save
      @licensee.change_status_for_super_admin
      redirect_to admin_licensees_path
    else
      render :action => 'new'
    end
  end

  def edit
    @licensee = User.unscoped.find(params[:id])
  end

  def update
    if params[:status]
      @licensee = User.unscoped.find_by_id(params[:id])
      if @licensee.present?
        @licensee.perform_event(params[:status]) 
      end
      redirect_to admin_licensees_path(:page => params[:page])
    elsif params[:deleted].present?
      @licensee = User.unscoped.find(params[:id])
      @licensee.update_column(:deleted,"#{params[:deleted]}")
      redirect_to admin_licensees_path(:page => params[:page])
    elsif params[:user]
      @licensee = User.unscoped.find(params[:id])
        if @licensee.update_attributes(licensee_params)
          redirect_to admin_licensees_path
        else
          render :action => "edit"
        end
    else
      render :action => "edit"
    end
  end


  def show
    @licensee = User.unscoped.find(params[:id])
    @clients = Client.with_roles(@licensee.roles.pluck(:name), @licensee)
    @event_count = @clients.map{|c| c.events.count}.sum
  end

  def destroy
    @licensee = User.unscoped.find(params[:id])
    if @licensee.destroy
      redirect_to admin_licensees_path
    end
  end

  protected

  def licensee_params
    params.require(:user).permit!
  end

  def set_current_licensee
    session['licensee_user_id'] = current_user.id
  end

end