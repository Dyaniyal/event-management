class Api::V5::InviteesController < ApplicationController
	skip_before_action :load_filter
	skip_before_action :authenticate_user!
  before_action :qr_code_access , :only => [:create]
  before_filter :check_for_mobile_application, :only => [:index]
  before_filter :check_for_event, :only => [:index]
  before_filter :check_for_invitee, :only => [:create, :show]
  before_filter :check_for_my_network_invitee, :only => [:create]
  before_filter :check_for_invitee_image, :only => [:update]
  respond_to :json
  
  def index
    data = Invitee.get_invitee_index_records(params)
    render :staus => 200, :json => {:status => "Success",
                                    :page_no => params[:page],
                                    :data => data}
  end

  def create
    if params["qr_code_scan"] == "true"
      favorite = Favorite.new(invitee_id: params["invitee_id"], favoritable_type: params["favoritable_type"], favoritable_id: params["favoritable_id"], event_id: params["event_id"])
      if favorite.save
        platform = (params["platform"].present? ? params["platform"] : "")
        favorite.qr_code_analytics(platform)
        data = Invitee.create_records(params)
        render :staus => 200, :json => {:status => "Success",
                                        :favorite => favorite.as_json(:only => [:id,
                                                                                :invitee_id,
                                                                                :favoritable_id,
                                                                                :favoritable_type,
                                                                                :status,
                                                                                :event_id]),
                                        :invitee => data } rescue []
      else
        render :status=>200,:json=>{:status=>"Failure",
                                    :message=>"You need to pass these values: #{favorite.errors.full_messages.join(" , ")}"}
      end
    else
      data = Invitee.my_network_invitee_records(params)
      render :staus => 200, :json => {:status => "Success",
                                      :invitee => data }
    end  
  end

  def show
    data = Invitee.get_invitee_show_records(params)
    render :staus => 200, :json => {:status => "Success", 
                                    :data => data} 
  end

  def update
    if @invitee.update(:profile_pic => params[:profile_pic])
      feature = @invitee.event.event_features.where(:name => "leaderboard") rescue nil
      if feature.present?
        analytic = Analytic.create(:viewable_type => 'Invitee',
                                   :viewable_id => @invitee.id,
                                   :action => 'profile_pic',
                                   :invitee_id => @invitee.id,
                                   :event_id => @invitee.event_id,
                                   :platform => params[:platform],
                                   :points => 5)
      else
        analytic = Analytic.create(:viewable_type => 'Invitee',
                                   :viewable_id => @invitee.id,
                                   :action => 'profile_pic',
                                   :invitee_id => @invitee.id,
                                   :event_id => @invitee.event_id,
                                   :platform => params[:platform],
                                   :points => 0)
      end
      render :status=>200,:json=>{:status=>"Success",
                                  :message=>"profile picture updated successfully.",
                                  :profile_pic_url => @invitee.profile_pic.url}
    else
      render :status=>200,:json=>{:status=>"Failure",
                                  :message=>"You need to pass these values: #{invitee.errors.full_messages.join(" , ")}" }
    end
  end

  private
  def qr_code_access 
    mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    favoritable_invitee = Invitee.find_by_id(params[:favoritable_id])
    if (params["qr_code_scan"] == "true") and mobile_application.present?
      event = favoritable_invitee.event
      mobile_app = event.mobile_application.submitted_code if favoritable_invitee.present? rescue nil
      if mobile_app != mobile_application.submitted_code or params[:event_id].to_i != event.id
        render :status => 200, :json => {:status => "Failure", :message => "Invitee does not belong to this event."}
      end
    elsif (params["qr_code_scan"] == "true") and mobile_application.blank?
      render :status => 200, :json => {:status => "Failure", message: "Mobile application not found."}  
    end
  end

  def check_for_mobile_application
    @mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_id(params["mobile_application_id"]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    if @mobile_application.blank?
      render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
    end 
  end 

  def check_for_event
    event_status = (params[:mobile_application_code].present? and @mobile_application.present? and @mobile_application.submitted_code == params[:mobile_application_code].upcase) ? ["published"] : ["approved","published"]
    @event = @mobile_application.events.where(:id => params[:event_id], :status => event_status) rescue nil
    if @event.blank?
      render :status => 200, :json => {:status => "Failure", :message => "Event Not Found."}
    end 
  end

  def check_for_invitee
    invitee = Invitee.find_by_id(params["invitee_id"])
    if invitee.blank?
      render :status=>200,:json=>{:status=>"Failure",:message=>"Invitee Not Found."}
    end
  end

  def check_for_my_network_invitee
    my_network_invitee = Invitee.find_by_id(params["favoritable_id"])
    my_network_invitee = (["deactive"].include?(my_network_invitee.visible_status) ? [] : my_network_invitee) if my_network_invitee.present?
    if my_network_invitee.blank?
      render :status=>200,:json=>{:status=>"Failure",:message=>"Invitee not Found."}  
    end 
  end

  def check_for_invitee_image
    @invitee = Invitee.where(:id => params[:id], :event_id => params[:event_id]).first rescue []
    if invitee.blank? and params[:profile_pic].blank?
      render :status=>200,:json=>{:status=>"Failure",:message=>"Invitee Not Found."}
    end
  end

end
#with pagination:- http://localhost:3000/api/v5//invitees.json?authentication_token=r61zZG8gB_KefARp6Y5V&key=afc18f10f203ad9dc7ed6523b130e1b036df6c5e&event_id=168&mobile_application_code=SVWXNP&page=2
#without pagination:- http://localhost:3000/api/v5//invitees.json?authentication_token=r61zZG8gB_KefARp6Y5V&key=afc18f10f203ad9dc7ed6523b130e1b036df6c5e&event_id=168&mobile_application_code=SVWXNP