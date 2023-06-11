class Admin::WarehouseTimersController < ApplicationController
	
	layout false
	before_filter :authenticate_user	

	def index
		@event = Event.find(params[:event_id])
		@invitees_count = @event.invitees.count 
		@order_picked =  @event.invitees.where(:successful_scan => true).count
		@order_dispatched = @event.invitees.where(:previous_scan => true).count
	end	

end
