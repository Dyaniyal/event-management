class Api::V1::PasswordsController < ApplicationController
  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  respond_to :json

  def index
    mobile_application = MobileApplication.find_by_preview_code(params['mobile_app_code']) || MobileApplication.find_by_submitted_code(params['mobile_app_code'])
    # if params[:mobile_application_preview_code].present? 
  #     mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
  #   elsif params[:mobile_application_code].present?
    #   mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params['mobile_app_code'], params['mobile_app_code']).first
    # end
    # mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params['mobile_app_code'], params['mobile_app_code']).first
    if mobile_application.present?
      event = Event.find_by_id(params[:event_id]) if params[:event_id].present?
      event_ids = event.present? ? [event.id] : mobile_application.events.pluck(:id) rescue []
      invitees = Invitee.where("event_id IN(?) and email =?", event_ids, params['email'])
      if invitees.present?
        invitee = invitees.first
        if invitee.email != 'preview@previewapp.com'
          pwd = invitee.email.first(4) rescue rand.to_s[2..5]
          pwd += rand.to_s[2..7]
          invitees.map{|n| n.update_attributes(:password => pwd, :invitee_password => pwd)}
        end
          event_smtp = Event.find_by_id(invitee.event_id)
          UserMailer.forgot_password_invitees(invitee,event_smtp).deliver_now
          render :status => 200, :json => {:status => "Success", :message => "Email Sent Successfully."}
      else
        render :status => 200, :json => {:status => "Failure", :message => "Invitee not found."}
      end
    else
      render :status => 200, :json => {:status => "Failure", :message => "Mobile Application not found."}
    end
  end

  def create
    mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    if mobile_application.present?
      submitted_app = "Yes" if params[:mobile_application_code].present? and mobile_application.present? and mobile_application.submitted_code == params[:mobile_application_code].upcase
      event_status = (submitted_app == "Yes" ? ["published"] : ["approved","published"])
      event_ids = mobile_application.events.where(:status => event_status).pluck(:id)
      if params[:key].present? and event_ids.present?
        invitee = Invitee.find_by_key(params[:key])
        invitees = Invitee.where("event_id IN(?) and email =?", event_ids, invitee.email) if invitee.present?
        if invitee.present?
          password = params[:current_password]
          if password.blank?
            render :status=>200,:json=>{:status=>"Failure",:message=>"Please provide current password."} and return
          else
            if (invitee.encrypted_password == BCrypt::Engine.hash_secret(password, invitee.salt))
              invitee.update_attributes(:password => params[:new_password], :invitee_password => params[:new_password])
              invitees.map{|i| i.update_attributes(:password => params[:new_password], :invitee_password => params[:new_password])} if invitees.present?
              render :status => 200, :json => {:status => "Success", :message => "Password successfully changed. Please Login to continue."}
            else
              render :status=>200,:json=>{:status=>"Failure",:message=>"Your current password entered is incorrect."} and return
            end
          end
        end
      else
        render :status => 200, :json => {:status=>"Failure", :message=>"Provide key."}
      end
    end
  end

end
