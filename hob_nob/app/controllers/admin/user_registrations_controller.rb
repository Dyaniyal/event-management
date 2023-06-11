class Admin::UserRegistrationsController < ApplicationController
	# layout 'admin'

  before_filter :find_event
  skip_before_filter :authenticate_user, :load_filter
  before_filter :authenticate_user, :only => [:index] 
  before_filter :find_registration_look_and_feels, only: [:new, :show, :create, :edit, :update]
  
  def index
    if (params[:my_status].present? and params[:my_status] == "Delete") and params[:registration_ids].present?
      params[:registration_ids].uniq.each do |i|
        user_registration = UserRegistration.find(i)
        user_registration.destroy
      end
      return redirect_to admin_event_user_registrations_path(:event_id => @event.id)
    end
    if params[:my_status].present?  and params[:registration_ids].present?
      params[:registration_ids].each do |i|
        user_registration = UserRegistration.find(i)
        status = params[:my_status].downcase.parameterize.underscore
        user_registration.update_column(:status, status)
      end
      return redirect_to admin_event_user_registrations_path(:event_id => @event.id)
    end
    @user_registration = @event.user_registrations.build
    @registration = @event.registrations.first
    if params["format"] == "xls" and params[:type].present? and params[:type] =="total"
      @user_registrations = @event.user_registrations
    else 
      @user_registrations = (params["format"].present? and params["format"] == "xls") ? (params["type"].present? ? @event.user_registrations.where(:status=>"#{params[:type]}") : @event.user_registrations) : @event.user_registrations.paginate(page: params[:page], per_page: 10)
    end
    respond_to do |format|
      format.html do
        @user_registrations = @user_registrations.paginate(page: params[:page], per_page: 10)
        render :layout => 'admin'
      end 
      if @registration.present? and params[:sample_download].present?
        format.xls do
          only_columns = @registration.selected_column_values
          method_allowed = [:timestamp]
          send_data [only_columns,method_allowed].to_reports_xls
        end
      else
        format.xls do
          @export_array = [@registration.selected_column_values.push("Status","Timestamp","Consent Question 1", "Consent Answer 1", "Consent Question 2", "Consent Answer 2", "Consent Question 3", "Consent Answer 3", "Consent Question 4", "Consent Answer 4", "Consent Question 5", "Consent Answer 5", "Consent Question 6", "Consent Answer 6", "Consent Question 7", "Consent Answer 7", "Consent Question 8", "Consent Answer 8", "Consent Question 9", "Consent Answer 9", "Consent Question 10", "Consent Answer 10", "Consent Question Timestamp").unshift("Registration ID")]
          method_allowed = []
          @only_columns = @registration.selected_columns
          @only_columns = @only_columns.push("status","timestamp")
          @consent_questions = ["consent_question_1", "consent_answer_1", "consent_question_2", "consent_answer_2", "consent_question_3", "consent_answer_3", "consent_question_4", "consent_answer_4", "consent_question_5", "consent_answer_5", "consent_question_6", "consent_answer_6", "consent_question_7", "consent_answer_7", "consent_question_8", "consent_answer_8", "consent_question_9", "consent_answer_9", "consent_question_10", "consent_answer_10", "date_timestamp"]
          for invitee in @user_registrations
            if invitee.id.present?
              timestamp = invitee.timestamp
              arr = @only_columns.map{|c|(invitee.attributes[c].present? ? invitee.attributes[c] + (invitee.text_box_for_checkbox_or_radiobutton.present? ? (invitee.text_box_for_checkbox_or_radiobutton[c].blank? ? "" : (" , " + invitee.text_box_for_checkbox_or_radiobutton[c][0].to_s)) : "" ) : "")}
              arr.last << timestamp
              arr.unshift(invitee.id)
              arr1 = @consent_questions.map{|c| invitee.attributes[c]}
              arr1.pop
              arr1 << invitee.consent_ques_answered_timezone
              @export_array << arr + arr1
            end 
          end
          send_data @export_array.to_reports_xls, filename: "registered_user_#{@registration.id}.xls"
        end
      end
    end
  end

  def new
    # if Rails.application.routes.recognize_path(request.referrer)[:controller] == "admin/registrations" 
    #   @custom_registration  = @registration.custom_source_code
    if params[:import].present?
      @import = Import.new
      render :layout => "admin"
    end
    if @event.registrations.present?
      @registration = @event.registrations.first 
      @user_registration = @event.user_registrations.build
      @registration_setting = @event.registration_settings.first
      if @registration_setting.registration == "hobnob" and @registration_setting.template == "custom"
        render :layout => false #"admin/layouts/user_registration"
      end
    else
      redirect_to admin_dashboards_path
    end
  end

  def create
    @registration = @event.registrations.first
    @registration_setting = @event.registration_settings.first

    @existing_user = UserRegistration.find_by(@registration.attributes["email_field"].downcase => params["user_registration"][@registration.attributes["email_field"].downcase], :event_id => params["event_id"]) if params["user_registration"][@registration.attributes["email_field"].downcase].present?
    if @existing_user.present?
      @user_registration = @existing_user
      @user_registration.assign_attributes(user_registration_params)
    else
      @user_registration = @event.user_registrations.build(user_registration_params)
    end  
    if @user_registration.save
      edm = Campaign.find_by_id(0).edms.where(:mail_to => @user_registration.status,:event_id => @user_registration.event_id).first
      edm.send_mail_to_register_user(@user_registration) if edm.present?  
      if @user_registration.walk_in_registration.present? and @user_registration.walk_in_registration == true
        @user_name = @event.badge_pdf.reg_match_name_field if @event.badge_pdf.present?
        if ["approved","confirmed"].include?(@user_registration.status)#@user_registration.status =="confirmed"
          @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now)
        end
        respond_to do |format|
          format.js
        end
      else
        if @user_registration.walk_in_registration.present? and @user_registration.walk_in_registration == true
          @user_name = @event.badge_pdf.reg_match_name_field if @event.badge_pdf.present?
          if ["approved","confirmed"].include?(@user_registration.status)#@user_registration.status =="confirmed"
            @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now)
          end
          respond_to do |format|
            format.js
          end
        else
          return redirect_to admin_event_user_registration_path(:event_id => @event.id,:id => @user_registration.id)
        end
      end
    else
      if @event.registration_settings.first.template == "custom" and params[:action] == "create"
        @registration_setting = @event.registration_settings.first
        render :action => 'new',:layout => "admin/layouts/user_registration.html.haml"
      elsif @user_registration.walk_in_registration.present? and @user_registration.walk_in_registration == true
        respond_to do |format|
          format.js
        end
      else
        render :action => 'new'
      end
    end
  end

  def show
    @message = (@registration_look_and_feel.present? && @registration_look_and_feel.thank_text.present?) ? @registration_look_and_feel.thank_text : 'User Registration Successful'
    @user_registration = UserRegistration.find_by_id(params[:id])
    @registration = @event.registrations.first
  end


  def edit 
    @user_registration = UserRegistration.find_by_id(params[:id])
    @registration = @event.registrations.first
    @registration_look_and_feel = @event.registration_look_and_feels.first if @event.registration_look_and_feels.present?
    @registration_setting = @event.registration_settings.first
    # render :layout => false
  end  

  def update
    @update = true
    @registration = @event.registrations.first
    @registration_setting = @event.registration_settings.first
    @registration_look_and_feel = @event.registration_look_and_feels.first if @event.registration_look_and_feels.present?
    if params[:from] == "all_listing"
      @user_registration = UserRegistration.find(params[:id])
      if @user_registration.update_attributes(user_registration_params.merge(mandate_empty_field))
        render :text => "<script>window.close();window.opener.location.href = window.opener.location.href</script>"
      else
        render action: 'edit'
      end
    elsif params[:onsite_form].present? and params[:onsite_form] == "true"
      @user_registration = UserRegistration.find(params[:id])
      if @user_registration.update_attributes(user_registration_params)
        unless @event.badge_pdf.skip_print
          redirect_to admin_event_qr_code_scanners_path(event_id: @event.id, user_registration_id: @user_registration.id, page: 'print_preview', from: 'invitee_search')
        else
          request.xhr? ? (render text: 'true') : (redirect_to :back)
        end
      else
        request.xhr? ? (render text: 'false') : (redirect_to :back)
      end
    else  
      @user_registrations = @event.user_registrations
      @user_registration = @user_registrations.find_by_id(params[:id])
      @user_registrations = @user_registrations.paginate(page: params[:page], per_page: 10)
      @user_registration.perform_event(params[:status]) if params[:status].present? and params[:manual_approve].present? and params[:manual_approve] == 'true'
      redirect_to :back
    end
    # redirect_to admin_event_user_registrations_path(:event_id => @user_registration.event_id)
  end

  def destroy
    @user_registration = UserRegistration.find_by_id(params[:id])
    @user_registration.destroy
    redirect_to admin_event_user_registrations_path
  end
   

  protected

  def mandate_empty_field
    @registration.attributes
      .select { |k, v| k.start_with?('field') && v['option_type'].in?(['Single Check Box','Check Box']) }
      .keys
      .inject({}) { |m, a| m[a] = '' unless user_registration_params.key?(a); m }
  end
  
  def find_event
    @event = Event.find(params[:event_id])
    if params[:from_onsite].present? and current_user.blank?
      session[:from_onsite] = "#{@event.id}" 
    end 
  end

  def user_registration_params
    params.require(:user_registration).permit! if params[:user_registration].present?
  end

  def find_registration_look_and_feels
    if @event.registration_look_and_feels.present?
      @registration_look_and_feel = @event.registration_look_and_feels.first
      @font_hash = Font.find_by(
        client_id: @registration_look_and_feel.event.client,
        font_name: @registration_look_and_feel.page_font
      ).font_hash rescue [{ font_name: @registration_look_and_feel.page_font }]
    else
      @font_hash = [{ font_name: '' }]
    end
  end

end
