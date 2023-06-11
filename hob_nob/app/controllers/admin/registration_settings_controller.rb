class Admin::RegistrationSettingsController < ApplicationController
  layout 'admin'

  before_filter :authenticate_user, :authorize_event_role, :find_features


  def index
    # if @registration_settings.present?
    #   redirect_to edit_admin_event_registration_setting_path(:event_id => params[:event_id], :id => @event.registration_settings.last.id)
    # else
    #   redirect_to new_admin_event_registration_setting_path(:event_id => params[:event_id])
    # end
    @registration_settings = @event.registration_settings.paginate(page: params[:page], per_page: 10)
  end

  def new
    if @event.present? and @event.registration_settings.present?
      redirect_to edit_admin_event_registration_setting_path(:event_id => params[:event_id], :id => @event.registration_settings.last.id)
    else
      @registration_setting = @event.registration_settings.build
    end
  end

  def create
    @registration_setting = @event.registration_settings.build(regi_setting_params)
    if @registration_setting.save
      if @registration_setting.registration == "hobnob"
        redirect_to admin_event_user_registrations_path(:event_id => @registration_setting.event_id)# if @event.registrations.blank?
        # redirect_to admin_event_registration_settings_path(:event_id => @event.id) if @event.registrations.present?
      else
        redirect_to admin_event_user_registrations_path(:event_id => @event.id)
      end
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @registration_setting.update_attributes(regi_setting_params)
      if @registration_setting.registration == "hobnob"
        redirect_to admin_event_user_registrations_path(:event_id => @registration_setting.event_id)# if @event.registrations.present?
        # redirect_to new_admin_event_registration_path(:event_id => @registration_setting.event_id) if @event.registrations.blank?
      else
        redirect_to admin_event_user_registrations_path(:event_id => @event.id)
      end
    else
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @registration_setting.destroy
      redirect_to admin_event_registration_settings_path(:event_id => @registration_setting.event_id)
    end
  end

  protected
  def regi_setting_params
    params.require(:registration_setting).permit!
  end
end
