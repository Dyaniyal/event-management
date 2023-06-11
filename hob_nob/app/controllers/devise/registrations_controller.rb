class Devise::RegistrationsController < DeviseController
#  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
#  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]

  skip_before_filter :load_filter, :only => [ :new, :create]#, :cancel]
  # GET /resource/sign_up
  def new
    resource = build_resource({})
#    respond_with resource
    respond_to do |format|
      format.html { render :action => "new" }
      format.json do
        @head_disabled = true
        @html = render_to_string(:layout => 'layouts/application.html.haml', :formats => [:html], :action => '../devise/registrations/new.html.haml')
        render :json => {:success => true, :value => @html.gsub('/assets', 'images') }
      end
    end
  end

  # POST /resource
  def create
    build_resource
    if resource.save
      # resource.confirm!
      if params[:user][:first_name].present?
        redirect_to users_path
        return true
      end  
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_to do |format|
          format.html { redirect_to admin_dashboards_path }
          format.json do
            @user = params[:username].present? ? User.find_by_username(params[:username]) : current_user
            @html = render_to_string(:layout => 'layouts/application.html.haml', :formats => [:html], :action => '../home/home.html.haml')
            render :json => {:success => true, :value => @html.gsub('/assets', 'images') }
          end
        end
#        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      respond_to do |format|
        format.html { render :action => '../devise/registrations/new'}
        format.json do
          @html = render_to_string(:layout => 'layouts/application.html.haml', :formats => [:html], :action => '../devise/registrations/new.html.haml')
          render :json => {:success => true, :value => @html.gsub('/assets', 'images') }
        end
      end
    end
  end

  # GET /resource/edit
  def edit
    respond_to do |format|
      format.html
      format.js
      format.json do
        @html = render_to_string(:layout => 'layouts/application.html.haml', :formats => [:html], :action => 'edit.html.haml')
        render :json => {:success => true, :value => @html.gsub('/assets', 'images') }
      end
    end
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if params[:user].present?
      if !params[:change_password].present?
        if resource.update_without_password(params[resource_name])
          if is_navigational_format?
            if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
              flash_key = :update_needs_confirmation
            end
            set_flash_message :notice, flash_key || :updated
          end
          sign_in resource_name, resource, :bypass => true
            respond_to do |format|
              format.js { render :action => "success"}
              format.html { respond_with resource, :location => after_update_path_for(resource) }
              format.json { render :json => {:value => "success"} }
            end
        else
          clean_up_passwords resource
          respond_to do |format|
            format.js { render :action => "success"}
            format.html { respond_with resource }
            format.json { render :json => {:errors => resource.errors} }
          end
        end
      else
        if params[:user][:password_confirmation].present? and params[:user][:password].present? and params[:user][:password] == params[:user][:password_confirmation]
          if resource.update_with_password(params[resource_name])
            if is_navigational_format?
              if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
                flash_key = :update_needs_confirmation
              end
              set_flash_message :notice, flash_key || :updated
            end
            sign_in resource_name, resource, :bypass => true
            respond_to do |format|
              format.js { render :action => "success"}
              format.html { respond_with resource, :location => after_update_path_for(resource) }
              format.json { render :json => {:value => "success"} }
            end
          else
            clean_up_passwords resource
            @current_password = (params[:user][:current_password].present? ? true : false)
            @new_password = (params[:user][:password].present? ? true : false)
            @not_matching = (params[:user][:password] == params[:user][:password_confirmation])? true : false
            respond_to do |format|
              format.js
              format.html { respond_with resource }
              format.json { render :json => {:errors => resource.errors} }
            end
          end
        else
          clean_up_passwords resource
          @current_password = (params[:user][:current_password].present? ? true : false)
          @new_password = (params[:user][:password].present? ? true : false)
          @not_matching = (params[:user][:password] == params[:user][:password_confirmation])? true : false
          respond_to do |format|
            format.js
            format.html { respond_with resource }
            format.json { render :json => {:value => "success"} }
          end
        end
      end
    else
      redirect_to edit_user_registration_path
    end
  end

  # DELETE /resource
  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_navigational_format?
    respond_with_navigational(resource){ redirect_to new_user_session_path }#after_sign_out_path_for(resource_name) }
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_registration_path(resource_name)
  end

  protected

  # Build a devise resource passing in the session. Useful to move
  # temporary session data to the newly created user.
  def build_resource(hash=nil)
    if params[:user].present?
      hash ||= user_params
    else
      hash ||= params[resource_name] || {}
    end
    self.resource = resource_class.new_with_session(hash, session)
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  # The path used after sign up for inactive accounts. You need to overwrite
  # this method in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    #respond_to?(:admin_dashboards_path) ? admin_dashboards_path : "/"
    respond_to?(:admin_dashboards_path) ? "/users/sign_in" : "/"
  end

  # The default url to be used after updating a resource. You need to overwrite
  # this method in your own RegistrationsController.
  def after_update_path_for(resource)
    # pratik
    #user_show_users_path(:username => resource.username)
    user_show_path(:username => resource.username)
  end

  # Authenticates the current scope and gets the current resource from the session.
  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", :force => true)
    self.resource = send(:"current_#{resource_name}")
  end
  
  def user_params
    params.require(:user).permit!
  end
  
end

