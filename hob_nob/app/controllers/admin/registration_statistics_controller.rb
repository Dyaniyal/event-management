class Admin::RegistrationStatisticsController < ApplicationController
  layout 'admin'
  skip_before_filter :authenticate_user!
  skip_before_filter :load_filter
  before_filter :authorize_event_role
  before_filter :registration_details, only: [:index, :show]

  def index
    @badge_pdf = @event.badge_pdf
    registration_field_count if @badge_pdf.present?
  	@target_attendee =  @event.registration_settings.present? ? @event.registration_settings.first.target_attendees : 0     
    @confirmed_registration = @registrations.count
  	@total_attendees = @registrations.where(qr_code_registration:true).count
  	@Pre_registered_attendees = @registrations.where(qr_code_registration:true,registration_type:"checkin").count
  	@onsite_attendees = @registrations.where(qr_code_registration:true,registration_type:"walkin").count
  	@no_shows = @registrations.where("qr_code_registration =?",false).count
  end

  def show
    @user_registrations = @registrations if params[:type].present? and  params[:type] =="confirmed"
		@user_registrations = @registrations.where(qr_code_registration:true) if params[:type].present? and  params[:type] =="total_attendees"
		@user_registrations = @registrations.where(qr_code_registration:true,registration_type:"checkin") if params[:type].present? and  params[:type] =="pre_registered"
		@user_registrations = @registrations.where(qr_code_registration:true,registration_type:"walkin") if params[:type].present? and  params[:type] =="walkin"
		@user_registrations = @registrations.where("qr_code_registration !=?",true) if params[:type].present? and  params[:type] =="no_shows"
    respond_to do |format|
      format.html do
        @user_registrations = @user_registrations.paginate(page: params[:page], per_page: 10)
      end
      format.xls do
        @export_array = [@registration.selected_column_values.push("status", "remark1","remark2","remark3","remark4","remark5")]
          method_allowed = []
          @only_columns = @registration.selected_columns
          @only_columns = @only_columns.push("status", "remark1","remark2","remark3","remark4","remark5")
          for invitee in @user_registrations
            arr = @only_columns.map{|c|(invitee.attributes[c].present? ? invitee.attributes[c] + (invitee.text_box_for_checkbox_or_radiobutton.present? ? (invitee.text_box_for_checkbox_or_radiobutton[c].blank? ? "" : (" , " + invitee.text_box_for_checkbox_or_radiobutton[c][0].to_s)) : "" ) : "")}
            @export_array << arr
          end
          send_data @export_array.to_reports_xls, filename: "Attendees.xls"
      end
    end
	end

  def registration_field_count
    columns = @registration.selected_column_values
    columns.each_with_index do |question_field, index|
      arr_values = @registrations.entered_users.map(&:"field#{index + 1}").compact
      arr_values.delete('')

      ('value_wise_field1').upto('value_wise_field9').to_a.each_with_index do |val_wise_field, index|
        if @badge_pdf.send("#{val_wise_field}").present? && @badge_pdf.send("#{val_wise_field}") == question_field
          instance_variable_set("@val_wise_count_field#{index + 1}", [arr_values, question_field])
        end
      end

      [:unique_field1 , :unique_field2, :unique_field3].each do |unique_field|
        if @badge_pdf.send("#{unique_field}").present? && @badge_pdf.send("#{unique_field}") == question_field
          instance_variable_set("@#{unique_field}_count", arr_values.uniq.count)
        end
      end

    end
  end

  private

  def registration_details
    @registration = @event.registrations.first
    @registrations = @event.user_registrations.where("status IN (?)",["approved","confirmed"])
  end

end
