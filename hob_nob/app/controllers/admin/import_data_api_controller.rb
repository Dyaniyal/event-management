class Admin::ImportDataApiController < ApplicationController
	layout 'admin'
	require 'api_import_invitee_data'
  
  before_filter :authenticate_user, :authorize_event_role
  before_filter :check_for_access, :only => [:index,:new]
	before_filter :check_for_licensee, :only => [:new]

	def new
		flash[:notice] = nil
		@import_data_api = ImportApi.new
	end
	
	def create
		@import_data_api = ImportApi.new(import_api_params)
		if @import_data_api.save
			response = HTTParty.get("https://dbms.shobizexperience.com/api/values/Getdata?username=#{@import_data_api.username}&password=#{@import_data_api.password}&tablename=#{@import_data_api.tablename}&pageno=#{@import_data_api.pagenumber}") 
	  	if response.present? and response["IsSuccess"]
	  		import_attribs = InviteeDatum.column_names 
	  		import_result = ApiImportInviteeData.save(response, 'InviteeDatum', params[:event_id].to_i,import_attribs, 'add', {})
	  		if import_result[:is_saved] == true
	        flash[:notice] = "File uploaded successfully."
	        redirect_to admin_event_invitee_structures_path(:event_id => params[:event_id].to_i)
        else
	      	@error_import = import_result[:excel_errors] rescue " "
	        render :action => 'new'
	      end
	  	else
	  		flash[:notice] = 'Please Enter valid credentials.' 	
	  		render :action => 'new'
	  	end
	  else 
    	render :action => 'new'
    end
	end
	
	protected

  def import_api_params
    params.require(:import_api).permit!
  end
  def check_for_licensee
  	if Rails.env == "production"
	  	redirect_to  admin_prohibited_accesses_path(:event => @event.id, :licensee_access => true) if current_user.parent.email != "shobiz@hobnobspace.com"
	  end
  end
end


