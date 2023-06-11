class Admin::OnsiteRegistrationsController < ApplicationController
	layout 'admin'
	before_filter :authenticate_user
	before_filter :find_event
	
	def index
		@badge_pdf = @event.badge_pdf
	end	

  protected

  def find_event
    @event = Event.find_by_id(params[:event_id])
  end

end
