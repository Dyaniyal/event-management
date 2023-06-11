class Admin::AutoStatusEmailsController < ApplicationController

	layout 'admin'
	before_filter :authenticate_user
	before_filter :find_event
	def new 
		@import = Import.new
	end

	protected
  
  def find_event
    @event = Event.find(params[:event_id])
  end

  def auto_status_email_params
    params.require(:auto_status_email).permit!
  end	

end
