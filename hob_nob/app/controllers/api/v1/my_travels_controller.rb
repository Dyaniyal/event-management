class Api::V1::MyTravelsController < ApplicationController
  before_action :load_filter
  skip_before_action :authenticate_user!
  before_action :my_travel_access , :only => [:index]
  respond_to :json
  def index
    if @invitee.present?
      my_travel = @invitee.my_travel
      if my_travel.present?
        render :staus => 200, :json => {:status => "Success",:my_travel => my_travel.as_json(:except => [:created_at, :updated_at, :attach_file_content_type, :attach_file_file_name, :attach_file_file_size, :attach_file_updated_at, :attach_file_2_file_name, :attach_file_2_content_type, :attach_file_2_file_size, :attach_file_2_updated_at, :attach_file_3_file_name, :attach_file_3_content_type, :attach_file_3_file_size, :attach_file_3_updated_at, :attach_file_4_file_name, :attach_file_4_content_type, :attach_file_4_file_size, :attach_file_4_updated_at, :attach_file_5_file_name, :attach_file_5_content_type, :attach_file_5_file_size, :attach_file_5_updated_at], :methods => [:attached_url,:attached_url_2,:attached_url_3,:attached_url_4,:attached_url_5, :attachment_type])} rescue []
      else
        render :status => 200, :json => {:status => "Failure", :message => "MyTravel Not Found."}
      end 
    else
      render :status => 200, :json => {:status => "Failure", :message => "Invitee Not Found."}
    end 
  end

  

  private

  def my_travel_access
    if params[:event_id].blank?
     render :status => 200, :json => {:status=>"Failure",:message=>"Event Id is required"}
     return
    end
    if params[:key].blank?
     render :status => 200, :json => {:status=>"Failure",:message=>"Key is required"}
     return
    end
    email = Invitee.where(:key => params[:key]).last.email rescue nil
    @invitee = Invitee.where(:event_id => params[:event_id], :email => email).last
  end
end