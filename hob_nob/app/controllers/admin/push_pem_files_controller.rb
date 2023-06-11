class Admin::PushPemFilesController < ApplicationController
  layout 'admin'

  #before_filter :authenticate_user, :authorize_mobile_application_role, :find_features
  before_filter :check_user_role
  before_filter :authorize_client_role, :find_mobile_application#, :find_client_association, :only => [:index, :show, :edit, :update, :create, :new], :if => Proc.new{params[:client_id].present?}

  def index
  end

  def new
    @mobile_application = MobileApplication.find(params[:mobile_application_id])
    @client = @mobile_application.client
    if @mobile_application.push_pem_file.nil?
      @push_pem_file = PushPemFile.new
    else
      redirect_to edit_admin_client_mobile_application_push_pem_file_path(:client_id => @mobile_application.client_id, :mobile_application_id => @mobile_application.id, :id => @mobile_application.push_pem_file.id)
      # edit_admin_client_mobile_application_push_pem_file_path(:client_id => @mobile_application.client_id, :mobile_application_id => @mobile_application.id, :id => @mobile_application.push_pem_file.id)
    end  
  end

  def create
    @push_pem_file = PushPemFile.new(push_pem_file_params)
    if @push_pem_file.save
      redirect_to admin_client_mobile_applications_path(:client_id => @mobile_application.client_id) if params[:client_id].present?
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @push_pem_file.update_attributes(push_pem_file_params)
      redirect_to admin_client_mobile_applications_path(:client_id => @mobile_application.client_id) if params[:client_id].present?
      # admin_mobile_applications_path //
      # redirect_to admin_event_mobile_applications_path(:event_id => @mobile_application.event_id) if params[:event_id].present?
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @push_pem_file.destroy
      redirect_to admin_mobile_application_push_pem_files_path(:mobile_application_id => @push_pem_file.mobile_application_id)
    end
  end

  protected

  def push_pem_file_params
    params.require(:push_pem_file).permit!
  end

  def find_mobile_application
    @mobile_applications = @client.mobile_applications
    @mobile_application = @mobile_applications.find(params[:mobile_application_id]) if params[:mobile_application_id].present?
    if @mobile_application.blank?
      return redirect_to admin_dashboards_path
    end
    @push_pem_file = @mobile_application.push_pem_file if params[:id].present?
  end

  def check_user_role
    if current_user.has_role? :db_manager 
      redirect_to admin_dashboards_path
    end  
  end
end
