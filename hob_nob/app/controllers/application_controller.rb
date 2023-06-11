class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
  before_action :load_filter, :check_licensee_expiry, :except => [:mobile_current_user_present]
  #before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_url_history, :except => :back
  before_action :set_current_user,:find_clients
  before_filter :telecaller_is_login
  before_action :check_license_activation
  #before_action :redirect_show_to_edit , :only => :show

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied!"
    redirect_to admin_dashboards_path
  end

  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def go_back 
    #Attempt to redirect
    redirect_to :back
 
    #Catch exception and redirect to root
    rescue ActionController::RedirectBackError
      redirect_to root_path
  end

  def load_filter
    if params[:key].present? 
      authenticate_user_from_token!
    elsif (["api/v1/events", "api/v1/activity_feeds","api/v2/events","api/v3/events","api/v4/events","api/v5/events"].include? params["controller"] and params["key"].blank?)
      session['invitee_id'] = nil
    else
      session['invitee_id'] = nil  
      authenticate_user!
    end
  end

  def check_licensee_expiry
    if (current_user.present? and !current_user.has_role? :super_admin)
      licensee_admin = current_user.get_licensee_admin
      if licensee_admin.present? and (licensee_admin.licensee_start_date.present? and licensee_admin.licensee_start_date > Date.today or licensee_admin.licensee_end_date.present? and licensee_admin.licensee_end_date < Date.today) and licensee_admin.status != "active"

        sign_out current_user
        session[:date_error] = "Your account is deactive, Please contact admin."
        root_path
        # if licensee_admin.licensee_start_date.present? and licensee_admin.licensee_start_date > Date.today
        #   session[:licensee_expired] = 'Your account has been expired. Kindly connect with hobnob team'
        #   redirect_to admin_dashboards_path if params[:controller] != 'admin/dashboards' and request.env['REQUEST_METHOD'] == 'POST'
        # elsif licensee_admin.licensee_end_date.present? and licensee_admin.licensee_end_date < Date.today
        #   session[:licensee_expired] = 'Your account has been expired. Kindly connect with hobnob team'
        #   redirect_to admin_dashboards_path if params[:controller] != 'admin/dashboards' and request.env['REQUEST_METHOD'] == 'POST'
        # elsif session[:licensee_expired].present?
        #   session[:licensee_expired] = nil
        # end
      end
    end
  end

  def set_current_user
    User.current = current_user
  end

  # def authorize_client_role
  #   client_ids = Client.with_roles(current_user.roles.pluck(:name), current_user).pluck(:id)
  #   @events = Event.with_roles(current_user.roles.pluck(:name), current_user)
  #   client_ids += @events.pluck(:client_id)
  #   @clients = Client.where(:id => client_ids)
  #   @client = @clients.find_by_id(params[:client_id])
  #   return redirect_to admin_dashboards_path if @client.blank?
  
  #   @events = @events.where(:client_id => @client.id)
  #   @events = @client.events if @events.blank? and @client.present?
  #   @event = @events.find_by_id(params[:id]) if params[:id].present? and @events.present?

  #   @log_changes = LogChange.get_changes('Event', @event.id) if params[:id].present? and @event.present?
    
  #   if params[:id].present? and @event.blank? and params[:controller] == 'admin/events'
  #     redirect_to admin_dashboards_path
  #   end
  # end

  def authorize_client_role
    client_ids = Client.with_roles(session[:current_user_role], current_user).pluck(:id)
    @events = Event.with_roles(session[:current_user_role], current_user)
    if client_ids.present?
      #@events += Event.where(:client_id => client_ids,:marketing_app => nil)
      @events += Event.where(:client_id => client_ids)
      @events = @events.flatten.uniq
    end
    
    #client_ids += @events.pluck(:client_id)
    client_ids += @events.map{|a|a.client_id}.compact.uniq
    @clients = Client.where(:id => client_ids)
    @client = @clients.find_by_id(params[:client_id])
    return redirect_to admin_dashboards_path if @client.blank?
  
    #@events = @events.where(:client_id => @client.id)
    event_ids = @events.map{|a|a.id}.compact.uniq
    #@events = Event.where('client_id IN (?) and id IN (?)', @client.id,event_ids).where(:marketing_app => nil)
    @events = Event.where('client_id IN (?) and id IN (?)', @client.id,event_ids)

    #@events = @client.events.where(:marketing_app => nil) if @events.blank? and @client.present?
    @event = @events.find_by_id(params[:id]) if params[:id].present? and @events.present?

    @log_changes = LogChange.get_changes('Event', @event.id) if params[:id].present? and @event.present?
    
    if params[:id].present? and @event.blank? and params[:controller] == 'admin/events'
      redirect_to admin_dashboards_path
    end
  end

  # def find_client_association
  #   features = params[:controller].gsub('admin/','')
  #   @events = Event.with_roles(current_user.roles.pluck(:name), current_user)
  #   @events = @events.where(:client_id => @client.id)
  #   if @events.blank?
  #     instance_variable_set("@"+features, @client.send(features)) if params[:action] == 'index'
  #   else
  #     instance_variable_set("@"+features, @events) if params[:action] == 'index'
  #   end
  #   ##Dont delete it #@attendee = @attendees.find_by_id(params[:id]) if params[:id].present? and @attendees.present?
  #   if @client.association(features).present? and params[:id].present?
  #     feature = @client.association(features).find(params[:id]) rescue nil
  #     instance_variable_set("@"+features.singularize, feature)
  #     instance_variable_set("@"+'log_changes', LogChange.get_changes(features.capitalize.singularize.camelize, feature.id)) if params[:action] == 'show'
  #   end
  #   redirect_to admin_dashboards_path if params[:id].present? and instance_variable_get("@"+features.singularize).blank?
  # end

  def find_client_association
    features = params[:controller].gsub('admin/','')
    @events = Event.with_roles(session[:current_user_role], current_user)
    client_ids = Client.with_role(session[:current_user_role], current_user).pluck(:id)
    if client_ids.present?
      @events += Event.where(:client_id => client_ids,:marketing_app => nil)
      @events = @events.flatten.uniq
    end
    #@events = @events.where(:client_id => @client.id)
    event_ids = @events.map{|a|a.id}.compact.uniq
    @events = Event.where('client_id IN (?) and id IN (?)', @client.id,event_ids).where(:marketing_app => nil)
    if @events.blank? and features == "events"
      instance_variable_set("@"+features, @events) if params[:action] == 'index'
    elsif @events.blank?
      instance_variable_set("@"+features, @client.send(features)) if params[:action] == 'index'
    else
      instance_variable_set("@"+features, @events) if params[:action] == 'index'
    end
    ##Dont delete it #@attendee = @attendees.find_by_id(params[:id]) if params[:id].present? and @attendees.present?
    if @client.association(features).present? and params[:id].present?
      feature = @client.association(features).find(params[:id]) rescue nil
      instance_variable_set("@"+features.singularize, feature)
      instance_variable_set("@"+'log_changes', LogChange.get_changes(features.capitalize.singularize.camelize, feature.id)) if params[:action] == 'show'
    end
    redirect_to admin_dashboards_path if params[:id].present? and instance_variable_get("@"+features.singularize).blank?
  end

  # def authorize_event_role
  #   @event = Event.find(params[:event_id]) rescue nil
  #   if @event.present?
  #     @assigned_event = Event.with_roles(current_user.roles.pluck(:name), current_user).where(:id => @event.id).first
  #     @client = Client.with_roles(current_user.roles.pluck(:name), current_user).where(:id => @event.client_id).first
  #     if (@client.blank? and @assigned_event.blank?)
  #       redirect_to admin_dashboards_path  
  #     end
  #   else
  #     redirect_to admin_dashboards_path
  #   end
  # end

  def authorize_event_role
    @event = Event.find(params[:event_id]) rescue nil
    if (params[:controller].present? and params[:controller] == "admin/edms")
      if (params[:preview].present? and params[:preview] == "true")
        edm = Edm.find_by_id(params[:id]) 
        @event = Event.find(edm.event_id) if edm.present?
      end
    end
    if @event.present?
      @assigned_event = Event.with_roles(session[:current_user_role], current_user).where(:id => @event.id).first
      @client = Client.with_roles(session[:current_user_role], current_user).where(:id => @event.client_id).first
      if (@client.blank? and @assigned_event.blank?)
        redirect_to admin_dashboards_path  
      end
    else
      redirect_to admin_dashboards_path
    end
  end

  def find_features
    #@attendees = @event.attendees
    features = params[:controller].gsub('admin/','')
    features = "event_features" if features == "menus"
    features = features.singularize if features == "mobile_applications" 
    features = features.singularize if features == "emergency_exits"
    features = features.singularize if features == "maps"
    instance_variable_set("@"+features, @event.send(features)) if params[:action] == 'index'
    
    ##Dont delete it #@attendee = @attendees.find_by_id(params[:id]) if params[:id].present? and @attendees.present?
    if @event.association(features).present? and params[:id].present?
      if features == "emergency_exit"
        feature = @event.emergency_exit rescue nil 
      elsif features == "map"
        feature = @event.map rescue nil 
      
      else
        feature = @event.association(features).find(params[:id]) rescue nil 
      end
      instance_variable_set("@"+features.singularize, feature)
      
      instance_variable_set("@"+'log_changes', LogChange.get_changes(features.capitalize.singularize.camelize, feature.id)) if params[:action] == 'show'
      
    end
    #redirect_to '/404.html' if @attendees.blank?
    redirect_to admin_dashboards_path if params[:id].present? and instance_variable_get("@"+features.singularize).blank?
  end
  
  def find_microsite_features
    #@attendees = @event.attendees
    features = params[:controller].gsub('admin/','')
    features = "microsite_features" if features == "microsite_menus"
    features = features.singularize if features == "microsites" 
    instance_variable_set("@"+features, @event.microsite.send(features)) if params[:action] == 'index'
    
    ##Dont delete it #@attendee = @attendees.find_by_id(params[:id]) if params[:id].present? and @attendees.present?
    if @event.microsite.association(features).present? and params[:id].present?
      feature = @event.microsite.association(features).find(params[:id]) rescue nil 
      instance_variable_set("@"+features.singularize, feature)
      
      instance_variable_set("@"+'log_changes', LogChange.get_changes(features.capitalize.singularize.camelize, feature.id)) if params[:action] == 'show'
    end
    redirect_to admin_dashboards_path if params[:id].present? and instance_variable_get("@"+features.singularize).blank?
  end
  

  def authenticate_user
    unless (user_signed_in? and current_user.present?)
      unless user_signed_in? 
        redirect_to admin_dashboards_path
      end
    end  
  end

  def authenticate_super_admin
    unless (user_signed_in? and current_user.roles.present? and current_user.has_role? :super_admin)
     redirect_to admin_dashboards_path
    end
  end



  def after_sign_in_path_for(resource)
    if resource.roles.blank? #resource.has_role? :super_admin or resource.has_role? :licensee_admin
      admin_dashboards_path
    elsif resource.has_role? :super_admin
      admin_licensees_path
    elsif false #resource.has_role? :telecaller
      session[:current_user_role] = "telecaller"
      #admin_clients_path(:feature => 'users',:redirect_page => 'index',:telecaller=>'true')
      #event_id = Grouping.where("id IN (?)",resource.assign_grouping).first.event_id
      #admin_event_telecaller_dashboards_path(:event_id => event_id,:user_id=>resource.id)
    else
      if session[:from_onsite].present?
        @event = Event.find_by_id(session[:from_onsite])
        session[:from_onsite] = nil
        session[:current_user_role] = User.current.roles.pluck(:name).uniq.first
        admin_event_user_registrations_path(:event_id => @event.id) 
      else
        new_admin_change_role_path# admin_dashboards_path
      end
      #end
    end
  end

  def set_url_history
    session[:skip_url_history] ||= false
    if session[:skip_url_history]
      session[:skip_url_history] = false
    else
      if ["create","update"].exclude?(params[:action]) 
        if (params["controller"] == "admin/clients" and params["action"] == "index"and params["client_id"] == "") or (params["controller"] == "admin/events" and params["action"] == "index"and params["event_id"] == "") or (params[:session_create] == "false")
        else
          session[:url_history] ||= []
          session[:url_history] << request.referrer unless session[:url_history].last == request.referrer
          session[:url_history].shift if session[:url_history].length == 10
        end  
      end
    end
    session[:url_history].compact if session[:url_history].present?
  end
 
  def back
    url = session[:url_history].pop
    session[:skip_url_history] = true
    redirect_to (url || "/")
  end
  
  def licensee_current_user
    if current_user.present? and current_user.has_role? :super_admin and session['licensee_user_id'].present?
      User.unscoped.find session['licensee_user_id']
    else
      current_user
    end
  end

  def find_clients
    if current_user.has_role? :super_admin
      @clients = Client.with_roles(current_user.roles.pluck(:name), current_user)
    else
      # client_ids = Client.with_roles(current_user.roles.pluck(:name), current_user).pluck(:id)
      # client_ids += Event.with_roles(current_user.roles.pluck(:name), current_user).pluck(:client_id)
      client_ids = Client.with_roles(session[:current_user_role], current_user).pluck(:id)
      client_ids += Event.with_roles(session[:current_user_role], current_user).pluck(:client_id)
      if (params["feature"].present? and params["feature"] == "marketing_apps" and params["redirect_page"].blank?)
        client_ids = Event.where(:client_id => client_ids,:marketing_app => true).where("mobile_application_id is not NULL").pluck(:client_id).uniq
      end
      @clients = Client.where(:id => client_ids)
    end if current_user.present?
    @client = @clients.find(params[:id]) rescue nil if params[:id].present? and @clients.present?
    @log_changes = LogChange.get_changes('Client', @client.id) if params[:id].present? and @client.present?
    
    # if ['show', 'edit', 'destroy', 'update', 'manage_users'].include? params[:action] and @client.blank?
    #   redirect_to admin_clients_path
    # end
  end

  def telecaller_is_login
    if (current_user.present? and current_user.has_role? :telecaller) #and (params[:controller] != "admin/telecallers" and params[:action] != "show"))
    #   redirect_to destroy_user_session_path, :method => :get
    end #if (params[:controller] != "admin/invitee_datas" and params[:action] != "update")
  end

  protected

  def configure_permitted_parameters
  	#devise_parameter_sanitizer.for(:sign_up) << :first_name, :last_name, :username, :pin_code, :mobile, :role, :email, :password
  	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:first_name, :last_name, :username, :pin_code, :mobile, :email, :password, roles: []) }
  	devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:first_name, :last_name, :username, :pin_code, :mobile, :email, :current_password, :password, :password_confirmation, roles: []) }
  	#devise_parameter_sanitizer.for(:account_update) << :first_name, :last_name, :username, :pin_code, :mobile, :role, :email, :password
  end

  def authenticate_user_from_token!
    key = params[:key].presence
    user = key && Invitee.find_by_key(key)
    if user.nil?
      render :status=>401, :json=>{:status=>"Failure", :status_code => 401, :message=>"Invalid Key."}
      session['invitee_id'] = nil
      return
    end
    if user && Devise.secure_compare(user.authentication_token, params[:authentication_token]) && user.authentication_token.present?
      #sign_in user, store: true
      session['invitee_id'] = user.id
      user.update_column(:last_interation, Time.now)
    else
      render :status=>401, :json=>{:status=>"Failure", :status_code => 401, :message=>"Invalid Authentication token."}
      return
    end
  end

  def mobile_current_user
    Invitee.find_by_id(session['invitee_id'])
    #session['invitee_id'].present?
  end

  def mobile_current_user_present
   session['invitee_id'].present?
  end

  # def redirect_show_to_edit
  #   # if params[:action] == "show" and ["admin/events","admin/mobile_applications","admin/clients","admin/polls"].exclude?(params[:controller]) and params[:controller].split('/').first != 'api'
  #   #   redirect_controller = params[:controller].split("/").second
  #   #   url = "/admin/events/#{params[:event_id]}/#{redirect_controller}/#{params[:id]}/edit"
  #   #   url = "/admin/events/#{params[:event_id]}/awards/#{params[:award_id]}/winners/#{params[:id]}/edit"  if params[:controller] == "admin/winners"
  #   #   redirect_to url
  #   # end
  # end
  

  # def check_for_access
  #   if (params[:format].present? and params["export_type"].blank? and current_user.has_role? :db_manager and ["admin/speakers","admin/feedbacks"].include? params[:controller])
  #     redirect_to admin_prohibited_accesses_path
  #   elsif params[:format].present? and !(current_user.has_role? :db_manager)
  #     redirect_to admin_prohibited_accesses_path
  #   end
  #   if (params[:import].present? and !(current_user.has_role? :db_manager) and params[:controller] == "admin/invitees")
  #     redirect_to admin_prohibited_accesses_path
  #   elsif (params[:import].present? and (current_user.has_role? :db_manager) and ["admin/invitees","admin/my_travels"].exclude? params[:controller])
  #     redirect_to admin_prohibited_accesses_path
  #   end
  #   if (["admin/invitees","admin/my_travels"].include? params[:controller] and ["index","new"].include? params[:action] and (!current_user.has_role? :db_manager))
  #     redirect_to admin_prohibited_accesses_path
  #   end
  # end

  def check_for_access
    if (params[:format].present? and params["export_type"].blank? and ["admin/speakers","admin/feedbacks"].include? params[:controller] and (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path
    elsif (params[:format].present? and params["export_type"].present? and ["admin/speakers","admin/feedbacks","admin/user_feedbacks"].include? params[:controller] and(!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path
    elsif (params[:format].present? and ["admin/speakers","admin/feedbacks"].exclude? params[:controller]and (!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path
    end
    if (["admin/telecaller_accessible_columns"].include? params[:controller] and ["new"].include? params[:action] and ((current_user.has_role_for_event?("client_admin", @event.id,session[:current_user_role])) or (current_user.has_role_for_event?("event_admin", @event.id,session[:current_user_role]))))
      redirect_to admin_prohibited_accesses_path 
    end  
    if (params[:import].present? and params[:controller] == "admin/invitees") and (!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]))
      redirect_to admin_prohibited_accesses_path
    elsif (params[:import].present? and params[:controller] == "admin/invitee_structures" and (current_user.has_role_for_event?("response_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path
    elsif (params[:import].present? and ["admin/invitees","admin/my_travels","admin/invitee_structures"].exclude? params[:controller] and (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path
    end
    if (["admin/invitees","admin/my_travels"].include? params[:controller] and ["index","new"].include? params[:action] and (!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path(:event => @event.id)
    elsif (["admin/invitee_searches","admin/campaigns"].include? params[:controller] and ["index","new"].include? params[:action] and (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]) or (current_user.has_role_for_event?("moderator", @event.id,session[:current_user_role]))))
      redirect_to admin_prohibited_accesses_path
	elsif (["admin/invitee_searches"].include? params[:controller] and ["index","new"].include? params[:action] and (current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path
    end
    if (["admin/invitee_structures"].include? params[:controller] and ["index","new"].include? params[:action] and (!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]) and !current_user.has_role_for_event?("response_manager", @event.id,session[:current_user_role])))
      redirect_to admin_prohibited_accesses_path(:event => @event.id)
    end
  end

  def check_license_activation
    if current_user.present?
      if current_user.license == true
        @licensee_acess = current_user 
        @check_mo_app_status = ((@licensee_acess.present? and @licensee_acess.activate_mobile_app.present?) ? @licensee_acess.activate_mobile_app =="yes" : true )
        @ems_acess = ((@licensee_acess.present? and @licensee_acess.activate_ems.present?) ? @licensee_acess.activate_ems =="yes" : true )  
      else
        @licensee_acess = User.find_by_id(current_user.licensee_id)    
        @check_mo_app_status = ((@licensee_acess.present? and @licensee_acess.activate_mobile_app.present?) ? @licensee_acess.activate_mobile_app =="yes" : true )
        @ems_acess = ((@licensee_acess.present? and @licensee_acess.activate_ems.present?) ? @licensee_acess.activate_ems =="yes" : true )
      end
    end    
  end

  def configure_cache_params
    params[:previous_date_time] = params[:previous_date_time].to_time.change(:sec => 0).utc.to_s if params[:previous_date_time].present?
    params[:is_invitee_group] = ""
    if params[:mobile_application_code].present? and params[:key].present?
      invitee = Invitee.find_by_key(params[:key]) if params[:key].present?
      if invitee.present?
        invitee_group_ids = invitee.get_invitee_groups
        params[:is_invitee_group] = invitee_group_ids.join if invitee_group_ids.present?
      end
    end
  end
end
