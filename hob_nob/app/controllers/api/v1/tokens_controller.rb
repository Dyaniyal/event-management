class Api::V1::TokensController < ApplicationController
  require 'tata_login'
  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  before_action :set_instances_for_get_key, :check_user_presence_for_get_key, :only => [:get_key]
  before_action :set_instances_for_create, :check_user_presence_for_create, :create_device_token_for_user, :only => [:create]
  respond_to :json 


  def index
    if params["token"].present?
      device = Device.find_by_token(params["token"])
      if device.present?
        device.update_column(:enabled, "false")
        session['invitee_id'] = nil
        render :status => 200, :json => {:status=>"Success", :message=>"Notification Stop successfully."}
      else
        render :status => 200, :json => {:status=>"Failure", :message=>"Device Not Found."}
      end
    else
      render :status => 200, :json => {:status=>"Failure", :message=>"Provide the device token."}
    end
  end
  
  def get_key
    @user.ensure_authentication_token if @user.present?
    if [38].include? @mobile_application.client_id and request.format != :json
      status = TataLogin.validate_email_password(@email, @password)
      @user.save if @user.present?
      if status == "Valid user" #or (@user.present? and @user.encrypted_password == BCrypt::Engine.hash_secret('password', @user.salt))
        @user = Invitee.unscoped.where(event_id:nil).first if @user.blank?
        respond_to do |format|
          format.js {render :js => "window.location.href = '#{@registration_setting.login_surl}?key=#{@user.key rescue nil}&secret_key=#{@user.secret_key rescue nil}'" }
          format.html{redirect_to "#{@registration_setting.login_surl}?key=#{@user.key rescue nil}&secret_key=#{@user.secret_key rescue nil}"}
        end
      else
        @status = 'Invalid Username or Password' and return
      end
    elsif @user.present? and not (@user.encrypted_password == BCrypt::Engine.hash_secret(@password, @user.salt))
      render :status=>200, :json=>{:status=>"Failure",:message=>"Invalid password."} and return
    else
      if @user.present?
        @user.save
        render :status=>200, :json=>{:status=>"Success",:secret_key=>@user.secret_key,:key=>@user.key,:answered_consent_questions=>@user.answered_consent_questions} and return
      end
    end
  end

  def create
    @user.ensure_authentication_token
    if @user and (@user.get_secret_key.present? and params[:secret_key].present? and @user.get_secret_key.bytesize == params[:secret_key].bytesize ) and @user.authentication_token.present?
      session['invitee_id'] = @user.id
      @new_user = "false"
      event = @user.event rescue nil
      check_invitee_first_login

      if @mobile_application.all_events_listing == "no"
        submitted_app = "Yes" if params[:mobile_application_code].present? and @mobile_application.present? and @mobile_application.submitted_code == params[:mobile_application_code].upcase
        allow_ids = @user.get_event_id(@mobile_application.submitted_code,submitted_app)
        all_events_data = Event.where(:id => allow_ids).as_json(:only => [:id, :event_name, :cities, :venues, :logo_updated_at, :status, :inside_logo_updated_at, :theme_id, :login_at, :event_category, :marketing_app, :start_event_time, :end_event_time, :description,:about], :methods => [:logo_url,:inside_logo_url])
      end
      render :status=>200, :json=>{:status=>"Success", :authentication_token=> @user.authentication_token, :user_id => @user.id, :user_name => @user.name_of_the_invitee, :new_user => @new_user, :event_ids => @user.get_event_id(@mobile_application.submitted_code,@submitted_app), :likes => @user.get_like(@mobile_application.submitted_code,@submitted_app), :user_polls => @user.get_user_poll(@mobile_application.submitted_code,@submitted_app), :ratings => @user.get_rating(@mobile_application.submitted_code,@submitted_app), :user_feedbacks => @user.get_user_feedback(@mobile_application.submitted_code,@submitted_app), :my_profile => @user.get_all_mobile_app_users(@mobile_application.submitted_code,@submitted_app), :my_network_invitee =>@user.get_my_network_users(@mobile_application.submitted_code,@submitted_app), :favorites => @user.get_favorites(@mobile_application.submitted_code,@submitted_app), :user_quizzes => @user.get_user_quizzes(@mobile_application.submitted_code,@submitted_app), :notifications => @user.get_notification(@mobile_application.submitted_code,@submitted_app), :invitee_notifications => @user.get_read_notification(@mobile_application.submitted_code,@submitted_app), :my_travels => @user.get_my_travels(@mobile_application.submitted_code,@submitted_app), :analytics => @user.get_analytics(@mobile_application.submitted_code,@submitted_app), :all_feedback_forms_last_updated_at => @user.all_feedback_forms_last_updated_at(@mobile_application.submitted_code,@submitted_app, nil),:all_events_data => all_events_data.present? ? all_events_data : []} and return
    else
      render :status=>200, :json=>{:status=>"Failure",:message=>"Invalid Scecret Key."} and return
    end
  end
 

  protected

  def redirect_to_url
    url = request.referrer.split('?').first
    parameter = '?' + ((request.referrer.include? '?') ? request.referrer.split('?').last : '')
    parameter += '&error_message=Invalid email/password' if !request.referrer.include? 'error_message' 
    url += parameter if parameter.present?
    encoded_url = URI.encode(url)
    @status = 'Invalid email/password'
  end

  def set_instances_for_get_key
    if params["mobile_application_code"].present? or params[:mobile_application_id].present? or params["mobile_application_preview_code"].present?
      @mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code]) || MobileApplication.find(params[:mobile_application_id]) 
      submitted_app = "Yes" if params[:mobile_application_code].present? and @mobile_application.present? and @mobile_application.submitted_code == params[:mobile_application_code].upcase
      event_status = (submitted_app == "Yes" ? ["published"] : ["approved","published"])

      @event = Event.find_by_id(params[:event_id]) if params[:event_id].present?
      if @event.present? and @event.parent_id.present? and @event.invitees.where(:email => params[:email]).blank?
        event_ids = [@event.parent_id]
      else 
        event_ids = [@event.id] if @event.present?
      end
      #event_ids = @mobile_application.events.where("status !=?","rejected").pluck(:id) rescue nil if event_ids.blank?
      if @mobile_application.events.where('status =? or status =? or status =?', "approved", "published", "confirmed").present?
        event_ids = @mobile_application.events.where(:status => event_status).pluck(:id) rescue nil if event_ids.blank?
        #event_ids = Event.where(:id => event_ids, :status =>  event_status).pluck(:id)
        @invitees = Invitee.where(:event_id => event_ids) rescue nil 
        #@invitees = Invitee.unscoped.where(:event_id => event_ids).order('updated_at DESC') rescue nil
        @user = @invitees.find_by_email(params[:email].downcase) rescue nil 
        if @user.present? and params[:agree_to_disclaimer_text].present?
          @user.update_column(:agree_to_disclaimer_text, params[:agree_to_disclaimer_text])
        end
        @registration_setting = RegistrationSetting.where(:event_id => params[:event_id]).last
        @registration_setting = RegistrationSetting.where(:event_id => event_ids).last if @registration_setting.blank? and @event.blank?
      end
    end
  end

  def check_user_presence_for_get_key
    @email, @password = params[:email], params[:password]
    if @email.blank? or @password.blank?
      if request.format == :json
        render :status=>200,:json=>{:status=>"Failure",:message=>"The request must contain the email and password."} and return
      else
        @status = 'Invalid Username or Password' and return
      end
    end
    if @user.nil?
      logger.info("User #{@email} failed signin, user cannot be found.")
      if request.format == :json
        render :status=>200, :json=>{:status=>"Failure",:message=>"Invalid email"} and return
      else
        @status = 'Invalid Username or Password'
      end
    end
  end

  def set_instances_for_create
    @mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params["mobile_application_code"]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    @submitted_app = ((params[:mobile_application_code].present? and @mobile_application.present? and @mobile_application.submitted_code == params[:mobile_application_code].upcase) ? "Yes" : "No")
    event_ids = @mobile_application.events.pluck(:id) rescue nil 
    @invitees = Invitee.where(:event_id => event_ids)  rescue nil 
    @user = @invitees.find_by_key(params[:key]) rescue nil 
    @user = Invitee.where(:event_id => nil).find_by_key(params[:key]) rescue nil if @user.blank? and @mobile_application.present? and @mobile_application.client_id == 38
    logger.info "-----------------------#{@user.inspect}--------------------------------------------------"
  end

  def check_user_presence_for_create
    secret_key, key = params[:secret_key], params[:key]
    if request.format != :json
      render :status=>200, :json=>{:status=>"Failure",:message=>"The request must be json"} and return
    end
    if secret_key.nil? or key.nil?
      render :status=>200, :json=>{:status=>"Failure",:message=>"The request must contain the secret key and key."} and return
    end
    if @user.nil?
      logger.info("User failed signin, user cannot be found.")
      render :status=>200, :json=>{:status=>"Failure",:message=>"User Not Found."} and return
    end
  end

  def create_device_token_for_user
    if (params[:token].present? and params[:platform].present?) and @mobile_application.present?
      device = Device.where(:token => params[:token]).first
      if device.present?
        device.update(:invitee_id =>  @user.id,:email => @user.email, :mobile_application_id => @mobile_application.id, :enabled => 'true')
      else
        Device.create(:invitee_id => @user.id, :token => params[:token], :platform => params[:platform], :email => @user.email,:mobile_application_id => @mobile_application.id, :enabled => 'true')
      end
    else
      render :status=>200, :json=>{:status=>"Failure",:message=>"Mobile Application Code Invalid and device token cant be blank."} and return
    end
  end

  def check_invitee_first_login
    @invitees.where(:email => @user.email).each do |user|
      event = user.event
      features = event.event_features.where(:name => "leaderboard") rescue nil if event.present?
      if features.present? and Analytic.where(:viewable_type => "Invitee", :viewable_id => user.id, :action => "Login", :invitee_id => user.id, :event_id => user.event_id, :points => 10).blank?
        analytic = Analytic.find_or_initialize_by(viewable_type: "Invitee", viewable_id: user.id, action: "Login", invitee_id: user.id, event_id: user.event_id, platform: params[:platform], :points => 10)
        analytic.save
        @new_user = "true"
      else
        @new_user = "true" if Analytic.where(:viewable_type => "Invitee", :viewable_id => user.id, :action => "Login", :invitee_id => user.id, :event_id => user.event_id).blank?
        analytic = Analytic.find_or_initialize_by(viewable_type: "Invitee", viewable_id: user.id, action: "Login", invitee_id: user.id, event_id: user.event_id, platform: params[:platform], :points => 0)
        analytic.save
      end
    end
  end
end
# def destroy_token
#   key = params[:key].presence
#   user = key && Invitee.find_by_key(key)
#   if user.nil?
#     render :status=>200, :json=>{:status=>"Failure",:message=>"Invalid Key."}
#     return
#   end
#   if user
#     #user.update_column(:authentication_token, nil)
#     if session['invitee_id'] == user.id
#       session['invitee_id'] = nil
#     end
#     render :status=>200, :json=>{:status=>"Success",:message=>"Authentication token set to nil"}
#     return
#   else
#     render :status=>200, :json=>{:status=>"Failure",:message=>"Invalid Authentication token."}
#     return
#   end
# end

# def user_sign_up
#   if params[:event_id].blank? or event = Event.find_by_id(params[:event_id]).present?
#     render :status => 200, :json => {:staus => "Failure", :message => "Event Not Found"}
#     return
#   end

#   if params[:name].blank?
#    render :status => 200, :json => {:status=>"Failure",:message=>"Name is required"}
#    return
#   end
  
#   if params[:email].blank?
#     render :status => 200, :json => {:status=>"Failure",:message=>"Email Address is required"}
#     return
#   else
#     event
#     user_exist = User.find_by_email(params[:email])
#     if user_exist.present?
#       render :status => 200, :json => {:status=>"Failure",:message=>"Another account is already using this email address"}
#       return
#     end   
#   end
  
#   # if params[:username].blank?
#   #   render :status => 200,
#   #           :json => {:status=>"Failure",:message=>"Username is required"}
#   #    return
#   # else
#   #   user_exist = User.find_by_username(params[:username])  
#   #   if user_exist.present?
#   #     render :status => 400,
#   #             :json => {:status=>"Failure",:message=>"Another account is already using this username"}
#   #     return
#   #   end          
#   # end

#   if params[:password].blank?
#     render :status => 200, :json => {:status=>"Failure",:message=>"Password is required"}
#      return
#   end
#   @user = Invitee.new({:email => params[:email], :name_of_the_invitee => params[:name],:password => params[:password], :status => true})
#   #@user.skip_confirmation!
#   if @user.save
#     @user.confirm!
#     @user.update_column(:loged_out, false)
#     sign_in @user, store: true
#     render :status => 200, :json => { :status=>"Success",
#             :secret_key => @user.secret_key,
#             :key => @user.key,
#             :authentication_token => @user.authentication_token,
#             :user_id => @user.id
#             }

#   else
#     logger.info @user.errors.inspect
#     render :status => 200, :json => { :status=>"Failure",:message=>"Registeration Failed Error: #{@user.errors.values.join(", ")}."}
#   end
# end
