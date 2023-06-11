class Admin::QrCodeScannersController < ApplicationController
  layout 'admin/layouts/scanner'

  skip_before_filter :authenticate_user!
  skip_before_filter :load_filter
  before_filter :authorize_event_role
  before_filter :redirect_to_https, :only => ["index"]
  before_filter :get_badge_setting, only: [:index, :show]

  def index
    @registration = @event.registrations.first
    if params[:print].present? and params[:print] == "qr_code_scanner"
      @user_registration = UserRegistration.find(params[:user_registration_id])
      @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now)
      if @badge_pdf.skip_print
        redirect_to admin_event_qr_code_texts_path(@event, user_reg_id: @user_registration.id) and return
      else
        return redirect_to :back
      end
    end
    if params[:print].present? and params[:print] == "all"
      @user_registration = UserRegistration.find(params[:user_registration_id])
      @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now)
      redirect_to admin_event_invitee_searches_path(:event_id => @event.id)
    end
    if params[:page].present? && params[:page]=="print_preview"
      @user_registration = @event.user_registrations.find_by_id(params[:user_registration_id])
      if @badge_pdf.try(:skip_print) and @user_registration.present?
        redirect_to admin_event_qr_code_texts_path(@event, user_reg_id: @user_registration.id)
      # elsif @user_registration.present? and  (@user_registration.qr_code_registration == false or @user_registration.qr_code_registration.nil?)
      #   if @user_registration.registration_type == "walkin"
      #     @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now, :status => (@user_registration.status == "rejected") ? @user_registration.previous_status : @user_registration.status)
      #   else
      #     @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now,:registration_type=>"checkin", :status => (@user_registration.status == "rejected") ? @user_registration.previous_status : @user_registration.status)
      #   end
      end
    end
    @autocomplete_data = UserRegistration.unscoped.where("status IN (?) and event_id = ?",["approved","confirmed"],@event.id).order(:qr_code_registration)
    if params[:email].present?
      @user_registrations = @autocomplete_data.where(
        @event.onsite_accessible_columns.selected_columns
          .map { |field| "#{field} like :search" }
          .join(' OR '),
        search: "%#{params[:email]}%"
      ).paginate(page: params[:invitees_page], per_page: 10)
    end

    @font_hash = Font.find_by(
      client_id: @event.client.id,
      font_name: @event.badge_pdf.printing_font_style
    ).font_hash rescue [{ font_name: '' }]
  end

  def show
    if params[:type].present? and params[:type]=="user_registration"
      #@user_registration = @event.user_registrations.where(:id=>params[:id],:status=>"confirmed").first# also check status
      @user_registration = @event.user_registrations.where("id= ? and status IN (?)", params[:id],["approved","confirmed"]).first
      if @user_registration.present?
        unless @badge_pdf.try(:skip_print)
          @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now,:registration_type=>"checkin")
        end
        respond_to do |format|
          format.js { render :js => "window.location.href = '#{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview', :user_registration_id => @user_registration.id)}'" }
        end
      else
        respond_to do |format|
          format.html{redirect_to admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview', :user_registration_absent=>'true')}
          format.js { render :js => "window.location.href = '#{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview',:user_registration_absent=>'true')}'" }
        end
      end
    else
      @invitee = @event.invitees.find_by_id(params[:id])
      if @invitee.present?
        @registration_settings = @event.registration_settings.first
        @registration = @event.registrations.first
        emailfield = @registration.email_field if @registration.present?
        @user_registration = @event.user_registrations.where("status IN (?)",["approved","confirmed"]).send("find_by_#{emailfield}","#{@invitee.email}")
        if @user_registration.present?
          @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now,:registration_type=>"checkin") unless @badge_pdf.try(:skip_print)
          respond_to do |format|
            format.html{redirect_to admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview',:user_registration_id=>@user_registration.id)}
            format.js { render :js => "window.location.href = '#{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview', :user_registration_id => @user_registration.id)}'" }
          end
        else
          respond_to do |format|
            format.html{redirect_to admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview', :invitee_absent=>'true')}
            format.js { render :js => "window.location.href = '#{admin_event_qr_code_texts_path(@event, invalid: true)}'" }
          end
        end
        #@user_registration = @event.user_registrations.find_by_email()
      else
        respond_to do |format|
        format.html{redirect_to admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview', :invitee_absent=>'true')}
        format.js { render :js => "window.location.href = '#{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'print_preview',:invitee_absent=>'true')}'" }
        end
      end
    # else
    #   @invitee = @event.invitees.find_by_id(params[:id])
    #   @invitee.update_column('qr_code_registration',true) if @invitee.present?
    #   @invitee.update_column('updated_at',Time.now) if @invitee.present?
    #   respond_to do |format|
    #     message = @invitee.present? ? "valid" : 'invalid'
    #     # format.js{render :js => "window.location.href = #{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'thank_you', :meassge => message)}" }
    #     invitee_id = @invitee.id rescue ''
    #     path = request.referer.include?('invitee_searches')
    #     if path
    #       format.js { render :js => "window.location.href = '#{admin_event_invitee_searches_path(:event_id => @event.id, :page => 'thank_you', :qr_code_preview => 'true', :meassge => message, :invitee_id => invitee_id)}'" }
    #       format.html
    #     else
    #       format.js { render :js => "window.location.href = '#{admin_event_qr_code_scanners_path(:event_id => @event.id, :page => 'thank_you', :qr_code_preview => 'true', :meassge => message, :invitee_id => invitee_id)}'" }
    #       format.html
    #     end
    #  end
    end
  end

  def redirect_to_https
    if Rails.env.production? or Rails.env.staging?
      redirect_to :protocol => "https://" unless request.protocol == "https://"
    end
  end

  protected

  def get_badge_setting
    @badge_pdf = @event.badge_pdf
  end

  def authorize_event_role
    @event = Event.find_by_id(params[:event_id])
    if @event.blank?
      redirect_to admin_dashboards_path
    end
  end
end