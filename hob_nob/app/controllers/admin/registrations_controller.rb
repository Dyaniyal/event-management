class Admin::RegistrationsController < ApplicationController
  layout 'admin'
  # load_and_authorize_resource :except => [:create]
  before_filter :authenticate_user
  before_filter :authorize_event_role, :if => Proc.new{params[:event_id].present?}

  def index
    if @event.registrations.present?
      # redirect_to edit_admin_event_registration_path(:event_id => params[:event_id],:id => @event.registrations.first.id)
      redirect_to admin_event_registration_settings_path(:event_id => params[:event_id],:id => @event.registrations.first.id)
    else
    redirect_to new_admin_event_registration_path(:event_id => params[:event_id])
    end
  end

  def new
    if @event.present? and @event.registration_settings.present? and @event.registrations.blank?
      @registration = @event.registrations.build 
    else @event.present? and @event.registration_settings.present? and @event.registrations.present?
      @registration = @event.registrations.first
      redirect_to edit_admin_event_registration_path(:event_id => params[:event_id],:id => @event.registrations.first.id)
    end
  end

  def create
    @registration = @event.registrations.build(registration_params)
    if @registration.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      else
        # redirect_to admin_client_event_path(:client_id => @event.client_id,:id => @registration.event_id)
        redirect_to admin_event_user_registrations_path(:event_id => @event.id)

      end
    else
      render :action => 'new'
    end
  end

  def edit
   @registration = @event.registrations.first
   if params[:change_code].present?
    @user_registration = @event.user_registrations.build
    if @registration.custom_source_code.blank?
      @source = render_to_string(:partial => 'admin/registrations/source_code', :layout => false)
      # @source = (render_to_string partial: '/comments/comment', locals: {comment: comment}, layout: false )
      @registration.update_attributes(:custom_source_code => @source.to_s)
    else
      @source = @registration.custom_source_code
    end
    #@source = File.open("public/_source_code.html.erb", "rb") {|io| io.read}
    end
  end

  def update
    @registration = @event.registrations.first
    if params[:field].present?
      @registration.update_column(
        "#{params[:field]}",
        Hash[%w(label option_type db_map_column_name invitee_map_column_name between_text option_1 option_2 option_3 option_4 option_5 option_6 option_7 option_8 option_9 option_10).map { |x| [x, ''] }].merge('validation_type' => 'Please Select')
      )
      @event.user_registrations.update_all(params[:field] => nil)
      redirect_to :back
    elsif params[:change_code].present?
      @registration.update_attributes(registration_params)
      redirect_to admin_event_registration_settings_path(:event_id => @event.id)
    elsif @registration.update_attributes(registration_params)
      # redirect_to admin_client_event_path(:client_id => @event.client_id,:id => @registration.event_id)
      redirect_to admin_event_user_registrations_path(:event_id => @event.id)
       
    else
      render :action => "edit"
    end
  end

  
  def destroy
    if @registration.destroy
      redirect_to admin_client_event_path(:client_id => @event.client_id,:id => @registration.event_id)
    end
  end

  def show
    # @registration =  @registration.custom_source_code
  end

protected

  def registration_params
    params.require(:registration).permit!
  end

end
