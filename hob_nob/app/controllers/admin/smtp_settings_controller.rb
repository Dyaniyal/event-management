class Admin::SmtpSettingsController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user, :find_smtp_setting, :find_event
  before_filter :set_back_url, :only => [:new,:edit]
  def index

  end

  def new
    if @smtp_setting.id.present?
      if params["event_id"].present? and @event.smtp_setting.present?
        @smtp_setting = @event.smtp_setting
        redirect_to edit_admin_smtp_setting_path(:id => @smtp_setting.id,:smtp_url => params[:smtp_url],:event_id => params["event_id"])
      elsif params["event_id"].present? and @event.smtp_setting.blank?
        @smtp_setting = @event.build_smtp_setting(@licensee_admin.smtp_setting.attributes.except('id', 'created_at', 'updated_at', 'user_id'))
      else
        redirect_to edit_admin_smtp_setting_path(:id => @smtp_setting.id,:smtp_url => params[:smtp_url])
      end
    else
      @smtp_setting = @licensee_admin.build_smtp_setting
    end  
  end

  def create
    if (params["smtp_setting"].present? and params["smtp_setting"]["event_id"].present?)
      @smtp_setting = @event.build_smtp_setting(smtp_setting_params)
    else
      @smtp_setting = SmtpSetting.new(smtp_setting_params)
    end
    if @smtp_setting.save
      @url = session[:smtp_url]
      session[:smtp_url] = nil
      redirect_to (@url || "/")
    else
      render :action => 'new'
    end
  end

  def edit
    if params["event_id"].present?
      if @event.smtp_setting.present?
        @smtp_setting = @event.smtp_setting
      end
    end
  end

  def update
    if params["smtp_setting"]["event_id"].present?
      @smtp_setting = @event.smtp_setting
    end
    if @smtp_setting.update_attributes(smtp_setting_params)
      @url = session[:smtp_url]
      session[:smtp_url] = nil
      redirect_to (@url || "/")
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @smtp_setting.destroy
      redirect_to new_admin_smtp_settings_path
    end
  end

  protected

  def find_smtp_setting
    @licensee_admin = current_user.get_licensee_admin
    @smtp_setting = @licensee_admin.smtp_setting
    @smtp_setting = @licensee_admin.build_smtp_setting if @smtp_setting.blank?
    redirect_to new_admin_smtp_setting_path if @smtp_setting.id.blank? and ['new', 'create'].exclude? params[:action]
  end

  def smtp_setting_params
    params.require(:smtp_setting).permit!
  end

  def set_back_url
    session[:smtp_url] = request.referer 
    @url = session[:smtp_url] 
  end

  def find_event
    if params["event_id"].present? or (params["smtp_setting"].present? and params["smtp_setting"]["event_id"].present?)
      @event = Event.find_by_id(params["event_id"]) || Event.find_by_id(params["smtp_setting"]["event_id"])
    end
  end
end
