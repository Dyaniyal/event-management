class Api::V1::InviteesController < ApplicationController
	skip_before_action :load_filter
	skip_before_action :authenticate_user!
  before_action :qr_code_access , :only => [:create]
	respond_to :json
	def index
		mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_id(params["mobile_application_id"]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
		#event_status = (params[:mobile_application_code].present? ? ["published"] : ["approved","published"]) 

    # if params[:mobile_application_preview_code].present?
    #   mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    # elsif params[:mobile_application_code].present? or params["mobile_application_id"].present?
    #   mobile_application = MobileApplication.where('submitted_code =? or preview_code =? or id =?', params[:mobile_application_code], params[:mobile_application_code], params["mobile_application_id"]).first
    # end
    
    event_status = (params[:mobile_application_code].present? and mobile_application.present? and mobile_application.submitted_code == params[:mobile_application_code].upcase) ? ["published"] : ["approved","published"]

		if mobile_application.present?
			events = mobile_application.events
			event = events.where(:id => params[:event_id], :status => event_status) rescue nil
			if event.present?
				invitee = Invitee.where(:key => params[:key]).last rescue nil
        if event.first.parent_id.present?
          invitees = Invitee.where(:event_id => event.first.parent_id, :visible_status => 'active') rescue []
          invitees_arr = []
          if invitees.present?
            invitees.each do |invitee|
              invitee_record = invitee
              invitee_record.event_id = event.first.id
              invitees_arr << invitee_record
            end  
          end
          invitees = invitees_arr  
        elsif params[:key].present? and invitee.present?
          invitees = Invitee.where('event_id = ? and visible_status = ? or event_id = ? and id = ?', event.first.id, 'active', event.first.id, invitee.id) rescue []
        else
          invitees = Invitee.where(:event_id => event.first.id, :visible_status => 'active') rescue []
        end
        render :staus => 200, :json => {:status => "Success",:invitees => invitees.as_json(:except => [:created_at, :updated_at, :badge_count, :encrypted_password, :salt, :key, :secret_key, :authentication_token],:methods => [:profile_picture]) } rescue []
			else
				render :status => 200, :json => {:status => "Failure", :message => "Event Not Found."}
			end	
		else
			render :status => 200, :json => {:status => "Failure", :message => "Mobile Application Not Found."}
		end	
	end

	def update
    invitee = Invitee.where(:id => params[:id], :event_id => params[:event_id]).first rescue []
    if invitee.present? and params[:profile_pic].present?
      if invitee.update(:profile_pic => params[:profile_pic])
        event = invitee.event rescue nil
        feature = event.event_features.where(:name => "leaderboard") rescue nil
        if feature.present?
          analytic = Analytic.create(:viewable_type => 'Invitee', :viewable_id => invitee.id, :action => 'profile_pic', :invitee_id => invitee.id, :event_id => invitee.event_id, :platform => params[:platform], :points => 5)
        else
          analytic = Analytic.create(:viewable_type => 'Invitee', :viewable_id => invitee.id, :action => 'profile_pic', :invitee_id => invitee.id, :event_id => invitee.event_id, :platform => params[:platform], :points => 0)
        end
        render :status=>200,:json=>{:status=>"Success",:message=>"profile picture updated successfully.", :profile_pic_url => invitee.profile_pic.url}
      else
        render :status=>200,:json=>{:status=>"Failure",:message=>"You need to pass these values: #{invitee.errors.full_messages.join(" , ")}" }
      end
    else
      render :status=>200,:json=>{:status=>"Failure",:message=>"Invitee Not Found."}
    end
  end

  def create
    invitee = Invitee.find_by_id(params["invitee_id"])
    if invitee.present?
      if params["qr_code_scan"] == "true"
        favorite = Favorite.new(invitee_id: params["invitee_id"], favoritable_type: params["favoritable_type"], favoritable_id: params["favoritable_id"], event_id: params["event_id"])
        if favorite.save
          platform = (params["platform"].present? ? params["platform"] : "")
          favorite.qr_code_analytics(platform)
          invitee = Invitee.find_by_id(favorite.favoritable_id)
          render :staus => 200, :json => {:status => "Success",:favorite => favorite.as_json(:only => [:id,:invitee_id, :favoritable_id, :favoritable_type, :status, :event_id]), :invitee => invitee.as_json(:only => [:first_name, :last_name, :designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location, :invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :points, :instagram_id, :profile_pic_updated_at, :qr_code_updated_at], :methods => [:qr_code_url,:profile_pic_url])} rescue []
        else
          render :status=>200,:json=>{:status=>"Failure",:message=>"You need to pass these values: #{favorite.errors.full_messages.join(" , ")}"}
        end
      else
        my_network_invitee = Invitee.find_by_id(params["favoritable_id"])
        my_network_invitee = (["deactive"].include?(my_network_invitee.visible_status) ? [] : my_network_invitee) if my_network_invitee.present?
        if my_network_invitee.present?
          render :staus => 200, :json => {:status => "Success",:invitee => my_network_invitee.as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location, :invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :instagram_id, :qr_code_updated_at, :profile_pic_updated_at], :methods => [:qr_code_url,:profile_pic_url]) } rescue []
        else
          render :status=>200,:json=>{:status=>"Failure",:message=>"Invitee not Found."}  
        end 
      end  
    else
      render :status=>200,:json=>{:status=>"Failure",:message=>"Invitee Not Found."}
    end
  end

  def show
    invitee = Invitee.find_by_id(params["invitee_id"])
    if invitee.present?
      render :staus => 200, :json => {:status => "Success",:invitee => invitee.as_json(:only => [:first_name, :last_name,:designation,:id,:event_name,:name_of_the_invitee,:email,:company_name,:event_id,:about,:interested_topics,:country,:mobile_no,:website,:street,:locality,:location, :invitee_status, :provider, :linkedin_id, :google_id, :twitter_id, :facebook_id, :instagram_id, :profile_pic_updated_at, :qr_code_updated_at], :methods => [:qr_code_url,:profile_pic_url]) } rescue []
    else
      render :status=>200,:json=>{:status=>"Failure",:message=>"Invitee Not Found."}
    end
  end

  private

  def qr_code_access 
    mobile_application = MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])

    # if params[:mobile_application_preview_code].present?
    #   mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    # elsif params[:mobile_application_code].present?
    #   mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params[:mobile_application_code], params[:mobile_application_code]).first
    # end

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
end