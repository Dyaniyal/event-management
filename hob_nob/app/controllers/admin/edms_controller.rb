class Admin::EdmsController < ApplicationController
  layout 'admin'
  Mime::Type.register "image/gif", :gif
  Mime::Type.register "image/png", :png
  Mime::Type.register "image/jpg", :jpg
  #load_and_authorize_resource
  skip_before_action :load_filter, :only => [:show]
  before_filter :authenticate_user, :authorize_event_role, :except => [:show]
  before_filter :get_event,:only => [:show]
  before_filter :find_edms
  before_action :find_fields_from_database, :only => [:new, :edit, :update, :create]
  before_filter :check_smtp_setting, :only => [:new, :index]
  before_filter :get_structure_fields, :only => [:new, :edit, :update, :create]

  def index
    @edms = @edms.ordered.paginate(page: params[:page], per_page: 10)
  end

  def new
    if params["auto_emailer"].present?
      @campaign = Campaign.find_by_id(0)
      @edm = Edm.new('campaign_id' => @campaign.id)
    else
      @edm = @campaign.edms.build
    end
  end

  def create
    @edm = @campaign.edms.build(edm_params)
    if @edm.save
      if params[:commit].present? and params[:commit] == "NEXT"
        redirect_to edit_admin_event_campaign_edm_path(:event_id => @edm.event_id, :campaign_id => @edm.campaign_id,:id => @edm.id,:next => params[:commit])
      else
        # redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
        redirect_to admin_event_campaign_edm_path(@edm.event_id,@edm.campaign_id,@edm.id, :mail_action => params[:edm][:mail_to])
      end
    else
      render :action => 'new'
    end
  end

  def edit

  end

  def update
    if params[:toggle] == 'true'
      @edm.toggle!(:active)
      return redirect_to admin_event_campaign_edms_path(event_id: @event.id, campaign_id: 0, email_setting: true)
    end
    if params[:remove_image].present? and params[:remove_image] =="true"
      @edm.header_image = nil
      @edm.save 
      return redirect_to edit_admin_event_campaign_edm_path(:event_id => @edm.event_id, :campaign_id => @edm.campaign_id,:id => @edm.id)
    end 
    if params[:broadcast_date].present?
      @edm.assign_attributes(edm_params) #if params[:edm][:group_type].present? and params[:edm][:group_type] == "apply filter"
      @edm.set_time(params[:edm][:start_date_time],params[:edm][:start_time_hour],params[:edm][:start_time_minute],params[:edm][:start_time_am]) if (params[:edm][:edm_broadcast_value].present? and params[:edm][:edm_broadcast_value] == "scheduled")
      @edm.check_sender_name_and_email_present if (params[:check_field_value].present? and params[:check_field_value] == "true")
      # in_zone = Time.now + 5.minutes
      # time = in_zone.in_time_zone("Mumbai")
      # @edm.set_time_for_now(time.strftime("%d/%m/%Y"),time.hour,time.min,time.strftime("%p")) if (params[:edm][:edm_broadcast_value].present? and params[:edm][:edm_broadcast_value] == "now")
      # @edm.edm_broadcast_time = Time.now if (params[:edm][:edm_broadcast_value].present? and params[:edm][:edm_broadcast_value] == "now")
      # @edm.edm_broadcast_value, @edm.group_type, @edm.flag, @edm.database_email_field = params[:edm][:edm_broadcast_value], params[:edm][:group_type], "1", params[:edm][:database_email_field]
      # @edm.group_id = params[:edm][:group_id] if params[:edm][:group_type].present? and params[:edm][:group_type] != "all"
      # @edm.group_id = @event.groupings.where(name:"Default Group").first.id if params[:edm][:group_type].present? and params[:edm][:group_type] == "all" and @event.groupings.present?
      # if @edm.sender_name.blank? #or @edm.cc.blank? or @edm.bcc.blank?
      #   return redirect_to edit_admin_event_campaign_edm_path(:event_id => @edm.event_id,:campaign_id => @edm.campaign_id,:id => @edm.id, :next=>"NEXT")
      # else
        if @edm.edm_broadcast_value == "scheduled"
          @edm.sent = 'no'
        end
        if params[:edm][:opt_for_unsubscribe].present?
          @edm.opt_for_unsubscribe = params[:edm][:opt_for_unsubscribe]
        end
        if @edm.save
          clear_error_messages
          @edm.send_mail_to_invitees if @edm.edm_broadcast_value == 'now' #and @edm.sent == 'no'
        else
          set_error_messages
          return redirect_to edit_admin_event_campaign_edm_path(:event_id => @edm.event_id,:campaign_id => @edm.campaign_id,:id => @edm.id, :next=>"NEXT")
        end
    else
      if params[:check_field_value].present? and params[:check_field_value] == "true"
        a = @edm.check_sender_name_and_email_present
      end
      @edm.update_attributes(edm_params)
    end
    if @edm.errors.blank?
      if params[:commit].present? and params[:commit] == "NEXT"
        redirect_to edit_admin_event_campaign_edm_path(:event_id => @edm.event_id, :campaign_id => @edm.campaign_id,:id => @edm.id,:next => params[:commit])
      elsif params[:commit].present? and params[:commit] == "SEND"
        redirect_to admin_event_campaign_edms_path(:event_id => @edm.event_id, :campaign_id => @edm.campaign_id)
      else
        update_mail = params["edm"]["update_mail"] if params["edm"]["update_mail"].present?
        step = params["edm"]["step"] if params["edm"]["step"].present?
        redirect_to admin_event_campaign_edm_path(@edm.event_id,@edm.campaign_id,@edm.id, :update_mail => update_mail, :mail_action => @edm.mail_to, :step => step)
      end
    else
      render :action => "edit"
    end
  end


  def show
    if params[:email_open].present? or request.format == "gif" or request.format == "png" or request.format == "jpg"
      edm = Edm.find(params[:id]) 
      email_sent = EdmMailSent.where(:edm_id => edm.id, :email => params[:user_email]).first
      if email_sent.present?
        email_sent.open = 'yes'
        email_sent.save 
      end
      respond_to do |format|
        format.html{}
        format.gif{send_data open("#{Rails.root}/public/Transparent.gif", "rb") { |f| f.read }}
        format.png{}
      end
    elsif params[:unsubscribe].present?
      # unsubscribe_user = Unsubscribe.where(:event_id => params[:event_id],:edm_id => params[:id],:email => params[:user_email]).first
      @unsubscribe_user = Unsubscribe.find_or_create_by(event_id: params[:event_id], email: params[:user_email])
      @unsubscribe_user.update_unsubscribe(params[:unsubscribe]) if @unsubscribe_user.present?
      redirect_to admin_unsubscribes_success_path
    elsif params[:user_email].present?
      if params[:campaign_id] == '0'
        registration_structure = @event.registrations.last
        @database_email_field = (registration_structure.present? ? (registration_structure.email_field.present? ? registration_structure.email_field : "") : "")
        @user_registration = @database_email_field ? UserRegistration.find_by(@database_email_field => params[:user_email]) : ''
      else
        invitee_structure = @event.invitee_structures.last
        @db_data = (invitee_structure.present? ? invitee_structure.invitee_datum : "")
        @database_email_field = (invitee_structure.present? ? (invitee_structure.email_field.present? ? invitee_structure.email_field : "") : "")
      end
      @email = params[:user_email]
      render :layout => false
    else
      render :layout => false
    end
  end

  def destroy
    if @edm.destroy
      redirect_to admin_event_campaign_edms_path(:event_id => @campaign.event_id, :campaign_id => @edm.campaign_id)
    end
  end

  def toggle_tele_assigned
    @edm.update_column(:telecaller_assigned, !@edm.telecaller_assigned)
    redirect_to admin_event_campaign_edms_path(@event, campaign_id: @edm.campaign_id)
  end

  protected

  def find_fields_from_database
    @fields = Grouping.get_default_grouping_fields(@event) if @event.invitee_structures.present? and @event.groupings.present?
  end

  def find_edms
    if params["auto_emailer"].blank?
      @campaign = @event.campaigns.find_by_id(params[:campaign_id])
      if @campaign.present?  
        @edms = @campaign.edms
        @edm = @edms.find_by_id(params[:id]) if params[:id].present? and @edms.present?
      end
    end  
  end

  def check_smtp_setting
    event = (@event || @campaign.event)
    licensee_admin = event.get_licensee_admin
    smtp_setting = licensee_admin.smtp_setting
    if smtp_setting.blank?
      redirect_to new_admin_smtp_setting_path(:smtp_url => params[:smtp_url])
    end
  end

  def edm_params
    params.require(:edm).permit!
  end

  def get_event
    @event = Event.find(params[:event_id])
  end

  def get_structure_fields
    if @event.present?
      if params['campaign_id'] == '0' && @event.registrations.first.present?
        @columns = @event.registrations.last.attributes.select { |k,v| k.start_with?('field') }
          .map{|k, v| v['label'].length > 0 ? [k,v['label'].downcase] : nil}.compact
        @columns = @columns.push(['qr_code', 'QR code']) if %w(approved confirmed).include? (params[:mail_to])
      elsif @event.invitee_structures.first.present?
        @columns = @event.invitee_structures.last.attributes.select { |k,v| k.start_with?('attr') }
          .map{|k, v| v.to_s.length > 0 ? [k,v.downcase] : nil}.compact
      end
    end
  end

  def set_error_messages
    session[:sender_name] = @edm.errors["sender_name"].join("") rescue nil
    session[:cc] = @edm.errors["cc"].join("") rescue nil
    session[:bcc] = @edm.errors["bcc"].join("") rescue nil
  end

  def clear_error_messages
    session[:sender_name] = nil
    session[:cc] = nil
    session[:bcc] = nil
  end
end