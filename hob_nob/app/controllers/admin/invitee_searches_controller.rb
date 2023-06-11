class Admin::InviteeSearchesController < ApplicationController
  before_filter :find_event
  before_filter :redirect_to_https, :only => ["index"]
  skip_before_filter :authenticate_user, :load_filter, :only => ["index"]
  def index
    @badge_pdf = @event.badge_pdf
    @user_registration = UserRegistration.find(params[:user_registration_id]) if params[:user_registration_id].present?
    if params[:print].present? and params[:print] == "all"
      if params[:change_type] == 'checkin' && @user_registration.registration_type.nil?
        @user_registration.update_column(:registration_type, 'checkin')
      end
      @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now)
      redirect_to admin_event_invitee_searches_path(:event_id => @event.id)
    end

    if params[:print] == 'confirmed'
      if @user_registration.present? and  (@user_registration.qr_code_registration == false or @user_registration.qr_code_registration.nil?)
        if @user_registration.registration_type == "walkin"
          @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now, :status => (@user_registration.status == "rejected") ? @user_registration.previous_status : @user_registration.status)
        else
          @user_registration.update_columns(qr_code_registration:true, qr_code_registration_time:Time.now, updated_at:Time.now,:registration_type=>"checkin", :status => (@user_registration.status == "rejected") ? @user_registration.previous_status : @user_registration.status)
        end
      end
    end

    if @event.registration_settings.present? and @event.registrations.present?
      if @event.registration_settings.first.registration == "hobnob"
        @registration = @event.registrations.first
        @user_registration = @event.user_registrations.build
        @registration_setting = @event.registration_settings.first
      end
    end
    if params["format"] == "xls" 
      @user_registrations = UserRegistration.unscoped.where("status IN (?) and event_id = ?",["approved","confirmed"],@event.id).order(:qr_code_registration)
    elsif params[:email].present? 
      @user_registrations = UserRegistration.unscoped.where("status IN (?) and event_id = ?",["approved","confirmed"],@event.id).order(:qr_code_registration)
      @user_registrations = @user_registrations.where(
        @event.onsite_accessible_columns.selected_columns
          .map { |field| "#{field} like :search" }
          .join(' OR '),
        search: "%#{params[:email]}%"
      ).paginate(page: params[:invitees_page], per_page: 10)
    elsif params["page"]=="walkin"
      @user_registrations = UserRegistration.unscoped.where("status IN (?) and event_id = ?",["approved","confirmed"],@event.id).order(:qr_code_registration).paginate(page: params[:invitees_page], per_page: 10)
    else 
      @user_registrations = UserRegistration.unscoped.where("status IN (?) and event_id = ?",["approved","confirmed"],@event.id).order(:qr_code_registration).paginate(page: params[:page], per_page: 10)
    end
    if params[:email].blank? and params["page"] !="walkin"
      respond_to do |format|
        format.html do
          @user_registrations = UserRegistration.unscoped.where("status IN (?) and event_id = ?",["approved","confirmed"],@event.id).order(:qr_code_registration).paginate(page: params[:page], per_page: 10)
        end 
        format.xls do
          @export_array = [@registration.selected_column_values.push("status", "remark1","remark2","remark3","remark4","remark5")]
          method_allowed = []
          @only_columns = @registration.selected_columns
          @only_columns = @only_columns.push("status", "remark1","remark2","remark3","remark4","remark5")
          @user_registrations = @user_registrations.entered_users
          for invitee in @user_registrations
            arr = @only_columns.map{|c|(invitee.attributes[c].present? ? invitee.attributes[c] + (invitee.text_box_for_checkbox_or_radiobutton.present? ? (invitee.text_box_for_checkbox_or_radiobutton[c].blank? ? "" : (" , " + invitee.text_box_for_checkbox_or_radiobutton[c][0].to_s)) : "" ) : "")}
            @export_array << arr
          end
          send_data @export_array.to_reports_xls, filename: "onsite_status#{@registration.id}.xls"
        end
      end
    end
  end
  # def index
  #   @invitees = @event.invitees
  #   @attendees = @event.invitees.unscoped.where(:qr_code_registration => true, :event_id => @event.id).order('updated_at desc')
  #   @attendance = @event.invitees.unscoped.where(:qr_code_registration => true, :event_id => @event.id).order('updated_at desc')
  #   # @comapny_names = @event.invitees.unscoped.where(:qr_code_registration => true, :event_id => @event.id).pluck(:company_name)
  #   @comapny_names = @event.invitees.unscoped.where("qr_code_registration = ? and event_id = ? and company_name != ?",true,@event.id,"").pluck(:company_name)


  #   @invitees = Invitee.search(params, @invitees) if params[:search].present? and ( params[:value].present? and params[:value] == "printBadge")
  #   @invitees = @invitees.paginate(page: params[:invitees_page], per_page: 10)

  #   @attendees = Invitee.search(params, @attendance) if (params[:search].present? and ( params[:value].present? and params[:value] == "attendee"))
  #   @attendees = @attendees.paginate(page: params[:attendees_page], per_page: 10)if params["format"] != "xls"
  #   if params[:page] == "thank_you"
  #     @invitee = @event.invitees.where(:id => params[:invitee_id]).last
  #   end
  #   if params[:page] == "manual_search"
  #     @invitee = @event.invitees.where(:id => params[:invitee_id]).last
  #     @invitee_searches = @event.invitees.where('email like ? or name_of_the_invitee like ?', "%#{params[:email]}%", "%#{params[:email]}%").paginate(page: params[:qr_scanner_page], per_page: 10) if params[:email].present?
  #   end

  #   respond_to do |format|
  #     format.html
  #     format.xls do
  #       #only_columns = [:name_of_the_invitee, :company_name, :designation, :mobile_no, :email]
  #       method_allowed = [:timestamp, :name_of_the_invitee, :company_name, :designation, :mobile_no, :email]
  #       # send_data @attendees.to_xls(:methods => method_allowed, :only => only_columns, :filename => "asd.xls")
  #       send_data @attendees.to_xls(:methods => method_allowed, :filename => "asd.xls")
  #     end
  #   end
  # end

  # def new
  #   if @event.present? and @event.custom_page1s.present?
  #     redirect_to edit_admin_event_custom_page1_path(:event_id => params[:event_id],:id => @event.custom_page1s.last.id)
  #   else
  #     @custom_page1 = @event.custom_page1s.build
  #   end
  # end

  # def create
  #   @custom_page1 = @event.custom_page1s.build(custom_page_params)
  #   if @custom_page1.save
  #     if params[:type].present?
  #       redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
  #     else
  #       redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
  #     end
  #   else
  #     render :action => 'new'
  #   end
  # end

  #def edit
    # @custom_page1 = @event.custom_page1s.last
  #end

  # def update
  #   if @custom_page1.update_attributes(custom_page_params)
  #     redirect_to admin_event_mobile_application_path(:event_id => @event.id,:id => @event.mobile_application_id,:type => "show_content")
  #   else
  #     render :action => "edit"
  #   end
  # end

  def show
    #render html: @custom_page1.description.html_safe
    # respond_to do |format|
    #   format.html { render :show => @custom_page1.description.html_safe , :layout => false }
    # end
    #render :layout => false
  end

  def redirect_to_https
    if Rails.env.production? or Rails.env.staging?
      redirect_to :protocol => "https://" unless request.protocol == "https://"
    end
  end

  protected

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end

  # def custom_page_params
  #   params.require(:custom_page1).permit!
  # end

end