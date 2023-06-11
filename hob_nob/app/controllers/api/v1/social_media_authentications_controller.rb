class Api::V1::SocialMediaAuthenticationsController < ApplicationController

  skip_before_action :load_filter
  skip_before_action :authenticate_user!
  respond_to :json

  def create
    provider = params[:provider]
    email = params[:email]
    
    mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_code]) || MobileApplication.find_by_submitted_code(params[:mobile_application_code]) || MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    
    # if params[:mobile_application_preview_code].present?
    #   mobile_application = MobileApplication.find_by_preview_code(params[:mobile_application_preview_code])
    # elsif params[:mobile_application_code].present?
    #   mobile_application = MobileApplication.where('submitted_code =? or preview_code =?', params[:mobile_application_code], params[:mobile_application_code]).first
    # end

    if mobile_application.present?
      event = mobile_application.events.where(:id => params['event_id']) if params['event_id'].present?
      event = mobile_application.events if event.blank?
    else
      render :status => 200,:json => {:status=>"Failure",:message=>"Mobile Application Not Found."}
      return
    end
    if provider.present? and event.present?
      if provider == 'facebook' and params['facebook_id'].blank?
        render :status => 200,:json => {:status=>"Failure",:message=>"Provide Facebook Id."}
        return
      elsif provider == 'linkedin' and params['linkedin_id'].blank?
        render :status => 200,:json => {:status=>"Failure",:message=>"Provide Linkedin Id."}
        return      
      elsif provider == 'google+' and params['google_id'].blank?
        render :status => 200,:json => {:status=>"Failure",:message=>"Provide Google Id."}
        return
      elsif provider == 'twitter' and params['twitter_id'].blank?
        render :status => 200,:json => {:status=>"Failure",:message=>"Provide Twitter Id."}
        return  
      elsif provider == 'instagram' and params['instagram_id'].blank?
        render :status => 200,:json => {:status=>"Failure",:message=>"Provide Instagram Id."}
        return  
      else
        user = Invitee.social_media_data(provider, params['facebook_id'], params['linkedin_id'], params['google_id'], params['twitter_id'], params['instagram_id'], email, params[:first_name], params[:last_name],event)
      end
            
    else
      render :status=>200, :json=>{:status=>"Failure", :message=>"The request must contain provider or event."}
      return
    end

    if user.present?
      if user.errors.present?
        render :status => 200,:json => {:status=>"Failure",:message=>"You need to pass these values: #{user.errors.full_messages.join(" , ")}"}
        return
      else  
        render :status=>200, :json=>{:status=>"Success",:secret_key=>user.secret_key,:key=>user.key}
        return
      end  
    else
    	render :status=>200, :json=>{:status=>"Failure",:message=>"User Not Found."}
      return	
    end

  end
end