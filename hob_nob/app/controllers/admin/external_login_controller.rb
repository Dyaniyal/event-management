class Admin::ExternalLoginController < ApplicationController

  layout 'admin/layouts/external_login'

  skip_before_filter :authenticate_user, :load_filter

  def index
  	@status = params[:error_message]
  	@event = Event.find_by_id(params[:event_id])
    @mobile_application = @event.mobile_application rescue nil ||  MobileApplication.where('preview_code = ? or submitted_code = ? or id = ?', params[:mobile_application_preview_code], params[:mobile_application_code], params[:mobile_application_id]).last 
    event_ids = @mobile_application.events.pluck(:id) rescue nil
    @registration_setting = RegistrationSetting.where(:event_id => params[:event_id]).last
  	@registration_setting = RegistrationSetting.where(:event_id => event_ids).last if @registration_setting.blank? and @event.blank?
  end

  def show
     
  end 
end
