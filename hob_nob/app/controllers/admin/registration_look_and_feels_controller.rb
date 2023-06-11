class Admin::RegistrationLookAndFeelsController < ApplicationController
  layout 'admin'

  # load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features
  before_filter :get_preview_form_url
    
  def index
    
  end

  def new
    if @event.registration_look_and_feels.present?
      redirect_to edit_admin_event_registration_look_and_feel_path(:event_id => @event.id,:id => @event.registration_look_and_feels.last.id)
    else
      @registration_look_and_feel = @event.registration_look_and_feels.build
    end
  end

  def create
    @registration_look_and_feel = @event.registration_look_and_feels.build(registration_look_And_feel_params)
    if @registration_look_and_feel.save
      redirect_to admin_event_user_registrations_path(:event_id => @event.id)
      #redirect_to "#{@regi_preview_form_url}?show_buttons=true"
    else
      @registration_look_and_feel.assign_attributes(logo_file_name: nil, banner_image_file_name: nil, body_background_image_file_name: nil, footer_image_file_name: nil)
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if (params[:remove_image].present? and params[:remove_image] == "true")
      @registration_look_and_feel.update_attribute(:banner_image, nil) if (@registration_look_and_feel.banner_image.present? and (params[:banner_image].present? and params[:banner_image] == "true"))
      @registration_look_and_feel.update_attribute(:body_background_image, nil) if (@registration_look_and_feel.body_background_image.present? and (params[:body_background_image].present? and params[:body_background_image] == "true"))
      @registration_look_and_feel.update_attribute(:footer_image, nil) if (@registration_look_and_feel.footer_image.present? and (params[:footer_image].present? and params[:footer_image] == "true"))
      @registration_look_and_feel.update_attribute(:logo, nil) if (@registration_look_and_feel.logo_file_name.present? and (params[:logo].present? and params[:logo] == "true"))
      redirect_to edit_admin_event_registration_look_and_feel_path(:event_id => @event.id, :id => @registration_look_and_feel.id)
    elsif @registration_look_and_feel.update_attributes(registration_look_And_feel_params)
      redirect_to admin_event_user_registrations_path(:event_id => @event.id)
      #redirect_to "#{@regi_preview_form_url}?show_buttons=true"
    else
      @registration_look_and_feel.errors.messages
        .map { |k,v| k.to_s.sub('_content_type', '') if k.to_s.end_with? ('_content_type') }
        .compact
        .each { |attachment| @registration_look_and_feel["#{attachment}_file_name"] = nil }
      render :action => "edit"
    end
  end

  def show
  end

  def destroy
    if @registration_look_and_feel.destroy
      redirect_to admin_event_user_registrations_path(:event_id => @event.id)
    end
  end

  protected

  def registration_look_And_feel_params
    params.require(:registration_look_and_feel).permit!
  end

  def get_preview_form_url
    if @event.present? and @event.registrations.present? and @event.registration_settings.present?
      regi_setting = @event.registration_settings.first
      @regi_preview_form_url = regi_setting.reg_url
      @client = @event.client
    end
  end

end
