class Admin::LogChangesController < ApplicationController
	#before_filter :authenticate_user, :authorize_event_role, :find_features
	layout 'admin'
    #skip_before_filter :authenticate_user, :load_filter, :only => [:index, :ipdate]
	def index
		@event = Event.find(params[:event_id]) if params[:event_id].present?
		#@client = Client.find(params[:client_id]) if params[:client_id].present?
		if params[:from] == "db"
      @log_changes = LogChange.where("resourse_type =? and event_id =? and action =?", "InviteeDatum", @event.id, "destroy").reverse.paginate(page: params[:page], per_page: 10)
    elsif  params[:invitee].present?
     	@log_changes = LogChange.where("resourse_type =? and event_id =? and action =?", "Invitee", @event.id, "destroy").reverse.paginate(page: params[:page], per_page: 10)
    elsif params[:from] == "user_registration"
    	@log_changes = LogChange.where("resourse_type =? and event_id =? and action =?", "UserRegistration", @event.id, "destroy").reverse.paginate(page: params[:page], per_page: 10)
    elsif params[:user_id].present? 
      @log_changes = LogChange.where(:user_id => params[:user_id], event_id: params[:event_id]).reverse.paginate(page: params[:page], per_page: 10)
	  elsif @event.present?
      @log_changes = LogChange.where(:event_id => @event.id).reverse.paginate(page: params[:page], per_page: 10)
    else
      @log_changes = LogChange.where(:user_id => current_user.id, event_id: params[:event_id]).reverse.paginate(page: params[:page], per_page: 10)
    end
	end

	def update
		LogChange.create(:resourse_type => params[:resourse_type], :resourse_id => params[:id],:action => "destroy")
		record = params[:resourse_type].constantize.find(params[:id])
		record.update_column("last_force_destroyed",Time.now)
		redirect_to :back
	end
end
