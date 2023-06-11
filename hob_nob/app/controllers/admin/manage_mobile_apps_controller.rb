class Admin::ManageMobileAppsController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user
  before_filter :authenticate_super_admin
  before_filter :set_store_info


  def index
    @manage_mobile_apps = @manage_mobile_apps.paginate(page: params[:page], per_page: 10)
    mobile_app = []
    @manage_mobile_apps.each do |store_info|
      mobile_app << MobileApplication.find(store_info.mobile_application_id)
    end
    @mobile_apps = mobile_app
  end   
  
  def update
    manage_mobile_apps = MobileApplication.find_by_id(params[:id])
    manage_mobile_apps.change_status(params[:status]) if params[:status].present? and manage_mobile_apps.present?
    redirect_to admin_manage_mobile_apps_path(:page => params[:page])
  end
  
  def show
    @mobile_application = MobileApplication.find(params[:id])
    @manage_mobile_app = StoreInfo.where(:mobile_application_id => "#{params[:id]}").first rescue []
  end

  protected
  def set_store_info
    @manage_mobile_apps = StoreInfo.where(:published_by_hobnob => "yes")
  end
end