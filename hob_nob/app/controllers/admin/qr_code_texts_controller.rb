class Admin::QrCodeTextsController < ApplicationController

  before_filter :get_scanned_users, only: :index
  skip_before_filter :load_filter, only: :index

  def index
    error_msg = "Can't find yourself? Please contact helpdesk for more assistance. Thank you."
    @user_registrations = @event.user_registrations.where("status IN (?) and event_id = ?",["approved","confirmed"],@event.id)
    @scanned_user_name = if @invitee.present?
      user_reg = @user_registrations.send("find_by_#{@event.registrations.first.email_field}", @invitee.email)
      if user_reg.present? and user_reg.reg_type_checkin?
        'Already Checked-In'
      elsif user_reg.present? and @invitee.check_same_event?(@event)
        user_reg.update_checkin_status
        "Welcome #{@invitee.name_of_the_invitee}"
      else
        error_msg
      end
    elsif @user_registration.present?
      if !@user_registration.check_same_event?(@event)
        error_msg
      elsif @user_registration.reg_type_checkin?
        'Already Checked-In'
      else
        "Welcome #{@user_registration.field2_and_field3}"
      end
    elsif params[:invalid].present?
      error_msg
    end
    if @user_registration.present? && @user_registration.registration_type.nil?
      @user_registration.update_checkin_status
    end
  end

  private

  def get_scanned_users
    @event = Event.find(params[:event_id])
    @badge_pdf = @event.badge_pdf
    @invitee = Invitee.find(params[:invitee_id]) rescue nil
    @user_registration = UserRegistration.find(params[:user_reg_id]) rescue nil
  end

end