class Admin::InviteesController < ApplicationController
  layout 'admin'

  #load_and_authorize_resource
  before_filter :authenticate_user, :authorize_event_role, :find_features#, :check_smtp_setting
  before_filter :check_for_access, :only => [:index,:new]
  before_filter :check_user_role, :except => [:index]
  before_filter :find_my_profiles, :only => [:edit, :new, :index]
  before_filter :find_invitee_visible_columns, :only => [:index]
  before_filter :send_mail_to_all, :only => [:index]

  def index
    if (params[:my_status].present? and params[:my_status] == "Delete") and params[:invitee_ids].present?
      params[:invitee_ids].each do |i|
        invitee = Invitee.find(i)
        invitee.destroy
      end
      return redirect_to admin_event_invitees_path(:event_id => params[:event_id])
    end
    @invitee = @event.invitees.build
    if params["send_mail"] == "true"
      if @event.mobile_application.present? and @event.mobile_application.application_type == "multi event" 
        event_ids = @event.mobile_application.events.pluck(:id)
        invitees = []
        @invitees.each do |invitee|
          # invitee1 = Invitee.where("event_id IN (?) AND email_send =? AND email =?", event_ids, "true", invitee.email).blank? ? invitee : nil
          invitee1 = Invitee.where("event_id IN (?) AND email_send =? AND email =? AND invitee_password =?", event_ids, "true", invitee.email, invitee.invitee_password).blank? ? invitee : nil
          invitees << invitee1
        end
        invitees = invitees.compact
      else 
        invitees = @invitees.where("email_send !=?", "true")
      end
      invitees.each do |invitee|
        UserMailer.send_password_invitees(invitee,@event).deliver_now 
        invitee.update_column(:email_send, 'true')
      end
    end
    if (params[:search].present? && params[:search][:company_name].present? && params[:search][:company_name] == "All") || (params[:search].present? && params[:search][:designation].present? && params[:search][:designation] == "All") || (params[:search].present? && params[:search][:order_by].present? && params[:search][:order_by] == "All") || (params[:search].present? && params[:search][:invitee_status].present? && params[:search][:invitee_status] == "All") || (params[:search].present? && params[:search][:visible_status].present? && params[:search][:visible_status] == "All") || (params[:search].present? && params[:search][:login_status].present? && params[:search][:login_status] == "All")
      @invitees
    else  
      @invitees = Invitee.search(params, @invitees) if params[:search].present?
    end
    @invitees = @invitees.paginate(page: params[:page], per_page: 10) if params["format"] != "xls"
    @registered_invitees = @invitees.where(qr_code_registration: true)
    respond_to do |format|
      format.html  
      format.xls do
        only_columns = [:id, :email, :first_name, :last_name, :company_name,:designation, :country, :website, :invitee_status]
        method_allowed = [:city, :description, :phone_number,:facebook, :google_plus, :linkedin, :twitter, :instagram, :logged_in, :Logged_in_time, :Profile_pic_URL,:Remark]
        send_data @invitees.to_xls(:only => only_columns,:methods => method_allowed, :filename => "asd.xls")
      end
    end
  end

  def new
    @invitee = @event.invitees.build
    @import = Import.new if params[:import].present?
  end

  def create
    @invitee = @event.invitees.build(invitee_params)
    if @invitee.save
      if params[:type].present?
        redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
      elsif params[:invitee][:invitee_searches_page].present?
        @invitee.update_column('onsite_registration',true)
        session[:invitee_serach_msg] = "Invitee created succsessfully"
        redirect_to admin_event_invitee_searches_path(:event_id => @event.id,:params_value => "onsite_registration")
      else
        redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
      end
    elsif params[:invitee][:invitee_searches_page].present?
      session[:invitee_serach_fname] = @invitee.errors[:first_name].join(" ")
      session[:invitee_serach_lname] = @invitee.errors[:last_name].join(" ")
      session[:invitee_serach_email] = @invitee.errors[:email].join(" ")
      redirect_to admin_event_invitee_searches_path(:event_id => @event.id,:params_value => "onsite_registration")  
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if params[:visible_status].present?
      @invitee.set_status(params[:visible_status])
      redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
    else
      if @invitee.update_attributes(invitee_params)
        redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
      else
        render :action => "edit"
      end
    end
  end

  def show
    if params["send_mail"] == "true"
      UserMailer.send_password_invitees(@invitee,@event).deliver_now
      @invitee.update_column(:email_send, "true")
      redirect_to admin_event_invitees_path(:event_id => @event.id)
    else
      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  def destroy
    if @invitee.destroy
      redirect_to admin_event_invitees_path(:event_id => @invitee.event_id)
    end
  end

  protected

  def check_user_role
    if (!current_user.has_role_for_event?("db_manager", @event.id,session[:current_user_role]))#(!current_user.has_role? :db_manager)
      redirect_to admin_dashboards_path
    end  
  end

  def invitee_params
    params.require(:invitee).permit!
  end

  def send_mail_to_all
    if params["send_mail"] == "true"
      if @event.mobile_application.present? and @event.mobile_application.application_type == "multi event" 
        event_ids = @event.mobile_application.events.pluck(:id)
        invitees = []
        @invitees.each do |invitee|
          invitee1 = Invitee.where("event_id IN (?) AND email_send =? AND email =?", event_ids, "true", invitee.email).blank? ? invitee : nil
          invitees << invitee1
        end
        invitees = invitees.compact
      else 
        invitees = @invitees.where("email_send !=?", "true")
      end
      invitees.each do |invitee|
        UserMailer.send_password_invitees(invitee,@event).deliver_now 
        invitee.update_column(:email_send, 'true')
      end
    end
  end

  def find_my_profiles
    @my_profile_attributes = @event.get_invitee_my_profile_attributes
  end

  def find_invitee_visible_columns
    if params[:format].present?
      @my_profile = MyProfile.where(:event_id => @event.id).last
      columns = @my_profile.enabled_attr rescue {}
      if @my_profile.present? and columns.present?
        @only_columns = columns.map{|column| column[1] == 'yes' ? column[0] : nil}.compact
        header_columns = @only_columns.map{ |x| (['attr1','attr2','attr3','attr4','attr5'].include? x) ? @my_profile.attributes[x] : x }
        @export_array = [header_columns + ['Logged In', 'profile_picture']]
      else
        @only_columns = ["email", "first_name", "last_name", "company_name", "designation", "mobile_no", "website", "street", "locality", "location", "country", "about", "interested_topics", "twitter_id", "facebook_id", "google_id", "linkedin_id", "instagram_id"]
        @export_array = [@only_columns + ['Logged In', 'profile_picture']]
      end
      if params[:sample_download].present?
        @only_columns += ['password', 'profile_picture']
        @only_columns = @only_columns.map{|column| Invitee::COLUMN_FOR_IMPORT_SAMPLE[column]}.compact

        @only_columns = @only_columns.map{ |x| (['attr1','attr2','attr3','attr4','attr5'].include? x) ? @my_profile.attributes[x] : x }
        @export_array = [@only_columns]
      end
    end  
  end
  
  def check_smtp_setting
    if current_user.get_smtp_setting.blank? and ['index', 'show'].include? params[:action]
      redirect_to new_admin_smtp_setting_path
    end
  end
end