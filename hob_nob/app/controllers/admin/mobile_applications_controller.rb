class Admin::MobileApplicationsController < ApplicationController
  require 'open-uri'
  layout 'admin'

  load_and_authorize_resource :except => [:create]
  before_filter :authenticate_user
  # before_filter :redirect_to_404, :only => [:index, :destroy], :if => Proc.new{params[:event_id].present?}
  # before_filter :redirect_to_404, :only => [:new, :create], :if => Proc.new{params[:client_id].present?}
  before_filter :authorize_event_role, :except => [:index], :if => Proc.new{params[:event_id].present?}
  before_filter :authorize_client_role, :find_client_association, :only => [:index, :show, :edit, :update, :create, :new], :if => Proc.new{params[:client_id].present?}


  def index
    if current_user.has_role_without_event("moderator",@clients,session[:current_user_role]) or current_user.has_role_without_event("event_admin",@clients,session[:current_user_role]) or current_user.has_role_without_event("db_manager",@clients,session[:current_user_role]) #current_user.has_role? :moderator or current_user.has_role? :event_admin or current_user.has_role? :db_manager
      mobile_app_id = @events.pluck(:mobile_application_id) rescue []
      @mobile_applications = MobileApplication.where("id IN (?) and client_id = ?",mobile_app_id,@client.id ) if mobile_app_id.present? #.where(:marketing_app_event_id => nil)
    else
      @mobile_applications = MobileApplication.where(:client_id => @client.id)#,:marketing_app_event_id => nil
    end
    if params[:feature].present?
      mobile_application_ids = @client.events.pluck(:mobile_application_id).compact
      single_mobile_application_ids = @mobile_applications.where('id IN (?) and application_type = ?', mobile_application_ids, 'single event').pluck(:id)
      @mobile_applications = @mobile_applications.where('id NOT IN (?)', single_mobile_application_ids) if single_mobile_application_ids.present?
      @select = true
    else
      @mobile_applications = MobileApplication.search(params, @mobile_applications) if params[:search].present?
      @mobile_applications = @mobile_applications.paginate(page: params[:page], per_page: 10)
    end
    if ((params[:search].present? && params[:search][:order_by].present? && params[:search][:order_by] == "single event") or (params[:search].present? && params[:search][:order_by].present? && params[:search][:order_by] == "multi event"))
      @mobile_applications = @mobile_applications.where("application_type = ? and client_id = ?", params[:search][:order_by], params[:client_id])
    end
  end

  def new
    #return redirect_to edit_admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application.id, :type => 'event_edit') if @event.mobile_application.present?
    if @client.present?
      @mobile_application = @client.mobile_applications.build
    elsif @clients.present?
      @mobile_application = @clients.first.mobile_applications.build
    end
    #@themes = Theme.find_themes(current_user)
    #@default_features = @event.set_features_default_list
    #@present_feature = @event.set_features rescue []
    #@mobile_applications = @client.mobile_applications.where(:application_type => 'multi event')
  end

  def create
    if @event.present? and params[:id].blank?
      redirect_to admin_client_mobile_applications_path(:client_id=>params[:client_id], :event_id=>params[:event_id], :feature=>"events", :session_create => false) and return if params[:add_existing] == "true"
      @mobile_application = @event.build_mobile_application(mobile_applications_params)
      if @mobile_application.save
        update_event_and_redirect and return
      else
        render :action => 'new'
      end
    else
      @mobile_application = @client.mobile_applications.build(mobile_applications_params) if params[:add_existing].blank?
      if @mobile_application.save
        create_mobile_app_and_redirect
      else
        render :action => 'new'
      end
    end
  end

  def edit
    if params[:download_image].present?
      url = params[:image_url]
      data = open(url).read
      send_data data, :disposition => 'attachment', :filename=> params[:image_name]
    else
      if @mobile_application.events.count == 1
        @event = @mobile_application.events.first
        params[:type] = "event_edit"
      end
      if params[:type] == "event_edit"
        @event = Event.find_by_id(params[:event_id]) || @event
        @themes = Theme.find_themes(@event)
        @default_features = @event.set_features_default_list
        @present_feature = @event.set_features rescue []
        @client = nil
      else
        @event_list = @client.events.pluck(:event_name,:id) rescue []
      end
      @client = @client.present? ? @client : @event.client
      @mobile_applications = @client.mobile_applications.where(:application_type => 'multi event')
    end
  end

  def update
    if params[:status].present?
      @mobile_application.mobile_app_status(params[:status])
      redirect_to admin_client_mobile_applications_path(:client_id => @client.id, :page => params[:page])
    elsif params[:type].present? and !(params[:enable_event].present? or params[:disable_event].present?)
      redirect_after_theme_update and return
    elsif params[:enable_event].present? or params[:disable_event].present?
      @event.add_single_features(params) if params[:enable_event].present?
      @event.remove_single_features(params) if params[:disable_event].present?
      respond_to{|format| format.js{} }
    elsif params[:remove_image] == "true"
      @mobile_application.update_attribute(:login_background, nil) if @mobile_application.login_background.present?
      redirect_to edit_admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
    else
      params[:mobile_application]["social_media_logins"] = nil if !params[:mobile_application].key?(:social_media_logins)
      if @mobile_application.update_attributes(mobile_applications_params)
        if @event.marketing_app == true
          @event.update_column(:event_name, @mobile_application.name)
          @event.update_attribute(:timezone, params[:timezone_landing_app][:timezone])
        end
        redirect_after_update
      else
        render :action => "edit"
      end
    end
  end

  def show
    # @resource_role = current_user.get_role_on_resource(@event)
    # if @resource_role.present? and @resource_role.name == 'moderator' and params[:type].blank?
    #   if (current_user.has_role_for_event?("moderator", @event.id,session[:current_user_role]))#current_user.has_role?(:moderator)
    #     redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id, :type => "show_engagement")
    #   else
    #     redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id, :type => "show_content")
    #   end
    # end
    @resource_role = Role.joins(:users).where('roles.resource_type = ? and resource_id = ? and name = ?', @event.class.name, @event.id, session[:current_user_role]).last#current_user.get_role_on_resource(@event)
    if @resource_role.present? and @resource_role.name == 'moderator' and params[:type].blank?
      if (current_user.has_role_for_event?("moderator", @event.id,session[:current_user_role]))#current_user.has_role?(:moderator)
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id, :type => "show_engagement")
      else
        redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id, :type => "show_content")
      end
    end
    if params[:analytics].present?
      hsh = {'Today' => (Date.today..Date.today), 'last 7 days' => (Date.today - 7.days)..Date.today}
      params[:start_date] = hsh[params[:filter_date]].first.strftime("%Y/%m/%d") if params[:filter_date].present? and params[:filter_date] != 'date range'
      params[:end_date] = hsh[params[:filter_date]].last.strftime("%Y/%m/%d") if params[:filter_date].present? and params[:filter_date] != 'date range'
      # @speaker_ids = Analytic.get_top_three_speaker_ids(@event.id, params[:start_date], params[:end_date])
      @speaker_ids = Rating.get_top_three_speaker_ids(@event.id, params[:start_date], params[:end_date])
      @pages = Analytic.get_top_three_pages(@event.id, params[:start_date], params[:end_date])
      @actions = Analytic.get_top_three_actions(@event.id, params[:start_date], params[:end_date])
      @event_features = Analytic.get_feature_usage(@event.id, params[:start_date], params[:end_date])
      @active_users = Analytic.get_active_users(@event.id, params[:start_date], params[:end_date])
      @unique_users = Analytic.get_unique_users(@event.id, params[:start_date], params[:end_date])
      if params[:filter_date].present? and params[:filter_date] == 'Today'
        @user_engagements = Analytic.get_today_user_engagements(@event.id, params[:start_date], params[:end_date])
      else
        @user_engagements = Analytic.get_user_engagements(@event.id, params[:start_date], params[:end_date], params[:filter_date])
      end
      @feature_count = Analytic.get_features_count(@event.id, params[:start_date], params[:end_date])

      # @xaxis_interval_labels = Analytic.get_x_axis_labels(@event.id, params[:start_date], params[:end_date])
      # @xaxis_interval_labels = Analytic.get_x_axis_labels(@event.id, params[:start_date], params[:end_date])
      @xaxis_interval_labels_and_interval = Analytic.get_x_axis_labels_and_interval(params)
      # @xaxis_time_splot = (params[:start_date].present? and params[:end_date].present? and (params[:end_date].to_date - params[:start_date].to_date).to_i > 30) ? (params[:end_date].to_date - params[:start_date].to_date).to_i / 30 : 1
      # @xaxis_time_splot = 1 if params[:filter_date].present? and params[:filter_date] == 'Today'
      # @xaxis_interval_labels = ['00:00', '01:00', '02:00', '03:00', '04:00', '05:00', '06:00', '07:00', '08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00', '24:00'] if params[:filter_date].present? and params[:filter_date] == 'Today'
    end
  end

  def destroy
    @client = Client.find(params[:client_id])
    if @mobile_application.destroy
      redirect_to admin_client_mobile_applications_path(:client_id => @mobile_application.client_id)
    end
  end


protected
  def redirect_to_404
    redirect_to '/404.html'
  end

  def mobile_applications_params
    #params.require(:mobile_application).permit(:application_type, :name, :app_icon, :splash_screen, :login_background, :listing_screen_background, :template_id).except(:event)
    # if params[:mobile_application][:event].present?
    #   params.require(:mobile_application).permit!.except(:event)
    # else
    #   params.require(:mobile_application).permit!
    # end
    if params[:mobile_application].present?
      params.require(:mobile_application).permit!.except(:event)
      params.require(:mobile_application).merge(:template_id => params[:template_id].first) if params[:template_id].present?
    end
  end

  def mobile_applications_event_params
    if params[:mobile_application].present? and params[:mobile_application][:event].present?
      params[:mobile_application].require(:event).permit!#.except(:event)
    end
  end

  def update_event_and_redirect
    @event.update_column(:mobile_application_id, @mobile_application.id)
    @event.update_column(:login_at , params['event']['login_at']) if params['event']['login_at'].present?
    @event.add_default_invitee
    @event.update_login_at_for_app_level
    #@mobile_application.update_column(:marketing_app_event_id, @event.id) if @event.marketing_app == true
    if @event.marketing_app == true
      @mobile_application.update_column(:marketing_app_event_id, @event.id)
      @event.update_column(:event_name, @mobile_application.name)
      @event.update_attribute(:timezone, params[:timezone_landing_app][:timezone])
      redirect_to "/admin/clients/#{@event.client_id}/events/#{@event.id}?analytics=true"  and return
    end
    redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @event.mobile_application_id)
  end

  def create_mobile_app_and_redirect
    @event = @client.events.find(params[:event_id]) if params[:event_id].present?
    if params["mobile_application"].present? and params["mobile_application"]["login_at"].present? and params["mobile_application"]["login_at"] == "Yes"
      @event.update_column(:login_at , nil) if params['event'].present? and params['event']['login_at'].present?
      @event.update_login_at_for_app_level
    else
      @event.update_column(:login_at , params['event']['login_at']) if params['event'].present? and params['event']['login_at'].present?
      @event.update_login_at_for_app_level
    end
    if params[:add_existing].present? or params[:old_one].present?
      @event.update_column(:mobile_application_id , @mobile_application.id)
      @event.add_default_invitee
      redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
    elsif params[:event_id].present?
      redirect_to admin_client_events_path(:client_id => @client.id)
    else
      redirect_to admin_client_events_path(:client_id => @client.id, :feature => 'mobile_application', :mobile_application_id => @mobile_application.id)
    end
  end

  def redirect_after_update
    if params["mobile_application"]["login_at"].present? and params["mobile_application"]["login_at"] == "Yes"
      @event.update_attribute(:login_at , nil) if params['event'].present? and params['event']['login_at'].present?
    else
      @event.update_attribute(:login_at , params['event']['login_at']) if params['event'].present? and params['event']['login_at'].present?
    end
    redirect_to admin_event_mobile_application_path(:event_id => @event.id, :id => @mobile_application.id)
  end

  def redirect_after_theme_update
    @event = Event.find(params[:event_id])
    if params[:step] == "select_theme"
      @event.update_column(:mobile_application_id, @mobile_application.id)
      if params["mobile_application"]["event"]["event_theme"] == "select from available theme"  and Theme.find_by_id(params[:theme_id])
        redirect_to new_admin_event_theme_path(:event_id => @event.id, :id => params[:theme_id].first, :step => "event_theme", :selected => true)
      else
        redirect_to new_admin_event_theme_path(:event_id => @event.id, :step => "event_theme")
      end
    end
  end

end